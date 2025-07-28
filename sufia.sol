// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Patient Medical Record Ownership with Selective Sharing
 * @dev A smart contract that allows patients to own and selectively share their medical records
 * @author MedChain Team
 */
contract Project {
    
    // Struct to represent a medical record
    struct MedicalRecord {
        uint256 recordId;
        address patient;
        string ipfsHash;        // IPFS hash of encrypted medical data
        uint256 timestamp;
        bool isActive;
        string recordType;      // e.g., "Lab Result", "X-Ray", "Prescription"
    }
    
    // Struct to represent access permissions
    struct AccessPermission {
        address provider;       // Healthcare provider address
        uint256 recordId;
        uint256 expirationTime;
        bool isActive;
        string purpose;         // Reason for access
    }
    
    // State variables
    uint256 private recordCounter;
    uint256 private permissionCounter;
    
    // Mappings
    mapping(uint256 => MedicalRecord) public medicalRecords;
    mapping(address => uint256[]) public patientRecords;
    mapping(uint256 => AccessPermission) public accessPermissions;
    mapping(address => uint256[]) public providerPermissions;
    mapping(uint256 => uint256[]) public recordPermissions; // recordId => permissionIds[]
    
    // Events
    event RecordCreated(
        uint256 indexed recordId,
        address indexed patient,
        string recordType,
        uint256 timestamp
    );
    
    event AccessGranted(
        uint256 indexed permissionId,
        address indexed patient,
        address indexed provider,
        uint256 recordId,
        uint256 expirationTime
    );
    
    event AccessRevoked(
        uint256 indexed permissionId,
        address indexed patient,
        address indexed provider
    );
    
    // Modifiers
    modifier onlyRecordOwner(uint256 _recordId) {
        require(medicalRecords[_recordId].patient == msg.sender, "Not the record owner");
        require(medicalRecords[_recordId].isActive, "Record is not active");
        _;
    }
    
    modifier validRecord(uint256 _recordId) {
        require(_recordId > 0 && _recordId <= recordCounter, "Invalid record ID");
        require(medicalRecords[_recordId].isActive, "Record is not active");
        _;
    }
    
    /**
     * @dev Core Function 1: Create a new medical record
     * @param _ipfsHash IPFS hash of the encrypted medical data
     * @param _recordType Type of medical record (e.g., "Lab Result", "X-Ray")
     * @return recordId The ID of the newly created record
     */
    function createMedicalRecord(
        string memory _ipfsHash,
        string memory _recordType
    ) external returns (uint256) {
        require(bytes(_ipfsHash).length > 0, "IPFS hash cannot be empty");
        require(bytes(_recordType).length > 0, "Record type cannot be empty");
        
        recordCounter++;
        uint256 newRecordId = recordCounter;
        
        medicalRecords[newRecordId] = MedicalRecord({
            recordId: newRecordId,
            patient: msg.sender,
            ipfsHash: _ipfsHash,
            timestamp: block.timestamp,
            isActive: true,
            recordType: _recordType
        });
        
        patientRecords[msg.sender].push(newRecordId);
        
        emit RecordCreated(newRecordId, msg.sender, _recordType, block.timestamp);
        
        return newRecordId;
    }
    
    /**
     * @dev Core Function 2: Grant access to a healthcare provider
     * @param _recordId ID of the medical record to share
     * @param _provider Address of the healthcare provider
     * @param _durationInDays Duration of access in days
     * @param _purpose Reason for granting access
     * @return permissionId The ID of the newly created permission
     */
    function grantAccess(
        uint256 _recordId,
        address _provider,
        uint256 _durationInDays,
        string memory _purpose
    ) external onlyRecordOwner(_recordId) returns (uint256) {
        require(_provider != address(0), "Invalid provider address");
        require(_provider != msg.sender, "Cannot grant access to yourself");
        require(_durationInDays > 0, "Duration must be greater than 0");
        require(bytes(_purpose).length > 0, "Purpose cannot be empty");
        
        permissionCounter++;
        uint256 newPermissionId = permissionCounter;
        
        uint256 expirationTime = block.timestamp + (_durationInDays * 1 days);
        
        accessPermissions[newPermissionId] = AccessPermission({
            provider: _provider,
            recordId: _recordId,
            expirationTime: expirationTime,
            isActive: true,
            purpose: _purpose
        });
        
        providerPermissions[_provider].push(newPermissionId);
        recordPermissions[_recordId].push(newPermissionId);
        
        emit AccessGranted(
            newPermissionId,
            msg.sender,
            _provider,
            _recordId,
            expirationTime
        );
        
        return newPermissionId;
    }
    
    /**
     * @dev Core Function 3: Revoke access from a healthcare provider
     * @param _permissionId ID of the permission to revoke
     */
    function revokeAccess(uint256 _permissionId) external {
        require(_permissionId > 0 && _permissionId <= permissionCounter, "Invalid permission ID");
        
        AccessPermission storage permission = accessPermissions[_permissionId];
        require(permission.isActive, "Permission is already inactive");
        
        uint256 recordId = permission.recordId;
        require(medicalRecords[recordId].patient == msg.sender, "Not authorized to revoke this permission");
        
        permission.isActive = false;
        
        emit AccessRevoked(_permissionId, msg.sender, permission.provider);
    }
    
    /**
     * @dev Check if a provider has valid access to a specific record
     * @param _provider Address of the healthcare provider
     * @param _recordId ID of the medical record
     * @return hasAccess Boolean indicating if provider has valid access
     */
    function checkProviderAccess(address _provider, uint256 _recordId) 
        external 
        view 
        validRecord(_recordId)
        returns (bool hasAccess) 
    {
        uint256[] memory permissions = recordPermissions[_recordId];
        
        for (uint256 i = 0; i < permissions.length; i++) {
            AccessPermission memory permission = accessPermissions[permissions[i]];
            
            if (permission.provider == _provider && 
                permission.isActive && 
                block.timestamp <= permission.expirationTime) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * @dev Get medical record details (only accessible by patient or authorized provider)
     * @param _recordId ID of the medical record
     * @return record The medical record details
     */
    function getMedicalRecord(uint256 _recordId) 
        external 
        view 
        validRecord(_recordId)
        returns (MedicalRecord memory record) 
    {
        MedicalRecord memory medRecord = medicalRecords[_recordId];
        
        // Allow access if caller is the patient or an authorized provider
        require(
            medRecord.patient == msg.sender || 
            this.checkProviderAccess(msg.sender, _recordId),
            "Access denied: Not authorized to view this record"
        );
        
        return medRecord;
    }
    
    /**
     * @dev Get all record IDs for a specific patient
     * @param _patient Address of the patient
     * @return recordIds Array of record IDs owned by the patient
     */
    function getPatientRecords(address _patient) 
        external 
        view 
        returns (uint256[] memory recordIds) 
    {
        require(_patient == msg.sender, "Can only view your own records");
        return patientRecords[_patient];
    }
    
    /**
     * @dev Get all permission IDs for a specific provider
     * @param _provider Address of the healthcare provider
     * @return permissionIds Array of permission IDs granted to the provider
     */
    function getProviderPermissions(address _provider) 
        external 
        view 
        returns (uint256[] memory permissionIds) 
    {
        require(_provider == msg.sender, "Can only view your own permissions");
        return providerPermissions[_provider];
    }
    
    /**
     * @dev Get permission details
     * @param _permissionId ID of the permission
     * @return permission The permission details
     */
    function getPermissionDetails(uint256 _permissionId) 
        external 
        view 
        returns (AccessPermission memory permission) 
    {
        require(_permissionId > 0 && _permissionId <= permissionCounter, "Invalid permission ID");
        
        AccessPermission memory perm = accessPermissions[_permissionId];
        MedicalRecord memory record = medicalRecords[perm.recordId];
        
        // Allow access if caller is the patient or the authorized provider
        require(
            record.patient == msg.sender || perm.provider == msg.sender,
            "Access denied: Not authorized to view this permission"
        );
        
        return perm;
    }
    
    /**
     * @dev Get total number of records created
     * @return count Total number of medical records
     */
    function getTotalRecords() external view returns (uint256 count) {
        return recordCounter;
    }
    
    /**
     * @dev Get total number of permissions created
     * @return count Total number of access permissions
     */
    function getTotalPermissions() external view returns (uint256 count) {
        return permissionCounter;
    }
}
