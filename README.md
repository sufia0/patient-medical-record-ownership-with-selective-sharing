# Patient Medical Record Ownership with Selective Sharing

## Overview

This project implements a patient-centric medical record management system that gives patients full ownership and control over their medical data while enabling selective sharing with healthcare providers, specialists, and authorized parties.

## Features

### Core Functionality
- **Patient Data Ownership**: Patients have complete control over their medical records
- **Selective Sharing**: Granular permissions for sharing specific data with chosen healthcare providers
- **Privacy Controls**: Fine-grained access controls with time-limited permissions
- **Data Portability**: Easy export and transfer of medical records between systems
- **Audit Trail**: Complete logging of all data access and sharing activities

### Security & Privacy
- End-to-end encryption for all medical data
- Zero-trust architecture
- HIPAA compliance
- Multi-factor authentication
- Blockchain-based consent management (optional)

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Patient App   │    │  Healthcare     │    │   Admin Panel   │
│                 │    │  Provider App   │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                ┌─────────────────────────────────┐
                │         API Gateway             │
                └─────────────────────────────────┘
                                 │
                ┌─────────────────────────────────┐
                │      Microservices Layer       │
                │  ┌─────────┐ ┌─────────────┐   │
                │  │  Auth   │ │   Records   │   │
                │  │ Service │ │   Service   │   │
                │  └─────────┘ └─────────────┘   │
                │  ┌─────────────┐ ┌─────────┐   │
                │  │   Sharing   │ │  Audit  │   │
                │  │   Service   │ │ Service │   │
                │  └─────────────┘ └─────────┘   │
                └─────────────────────────────────┘
                                 │
                ┌─────────────────────────────────┐
                │        Database Layer           │
                │  ┌─────────────────────────┐   │
                │  │    Encrypted Medical    │   │
                │  │    Records Database     │   │
                │  └─────────────────────────┘   │
                └─────────────────────────────────┘
```

## Getting Started

### Prerequisites
- Node.js 18+ or Python 3.9+
- Docker and Docker Compose
- PostgreSQL 14+
- Redis 6+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/patient-record-ownership.git
cd patient-record-ownership
```

2. Install dependencies:
```bash
# For Node.js
npm install

# For Python
pip install -r requirements.txt
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Start the services:
```bash
docker-compose up -d
```

5. Run database migrations:
```bash
# Node.js
npm run migrate

# Python
python manage.py migrate
```

6. Start the application:
```bash
# Development mode
npm run dev
# or
python manage.py runserver
```

## Usage

### For Patients
1. Register and verify your account
2. Upload medical records or connect to healthcare providers
3. Set sharing permissions for different data types
4. Grant time-limited access to healthcare providers
5. Monitor access through the audit dashboard

### For Healthcare Providers
1. Register as a healthcare provider (requires verification)
2. Request access to patient records
3. View granted medical data within permitted timeframes
4. Add new medical records with patient consent

## API Documentation

### Authentication
All API endpoints require authentication via JWT tokens.

### Key Endpoints

#### Patient Management
- `POST /api/patients/register` - Patient registration
- `GET /api/patients/profile` - Get patient profile
- `PUT /api/patients/profile` - Update patient profile

#### Medical Records
- `POST /api/records` - Upload medical record
- `GET /api/records` - Get patient's records
- `PUT /api/records/{id}` - Update record
- `DELETE /api/records/{id}` - Delete record

#### Sharing & Permissions
- `POST /api/sharing/grant` - Grant access to provider
- `PUT /api/sharing/{id}/revoke` - Revoke access
- `GET /api/sharing/permissions` - List active permissions

### Example Request
```bash
curl -X POST \
  https://api.example.com/api/sharing/grant \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "provider_id": "provider-123",
    "record_types": ["lab_results", "prescriptions"],
    "expiry_date": "2024-12-31T23:59:59Z",
    "purpose": "routine_checkup"
  }'
```

## Configuration

### Environment Variables
```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=patient_records
DB_USER=your_db_user
DB_PASSWORD=your_db_password

# Security
JWT_SECRET=your-jwt-secret
ENCRYPTION_KEY=your-encryption-key

# External Services
HEALTHCARE_API_URL=https://api.healthcare-system.com
NOTIFICATION_SERVICE_URL=https://notifications.example.com
```

## Testing

Run the test suite:
```bash
# Unit tests
npm test
# or
python -m pytest

# Integration tests
npm run test:integration
# or
python -m pytest tests/integration/

# End-to-end tests
npm run test:e2e
```

## Deployment

### Production Deployment
1. Build the application:
```bash
npm run build
# or
python manage.py collectstatic
```

2. Deploy using Docker:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

3. Set up SSL certificates and configure reverse proxy

### Environment-specific Configurations
- **Development**: `config/development.yml`
- **Staging**: `config/staging.yml`
- **Production**: `config/production.yml`

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow the existing code style
- Write tests for new features
- Update documentation as needed
- Ensure HIPAA compliance for any healthcare-related changes

## Security Considerations

- All medical data is encrypted at rest and in transit
- Regular security audits and penetration testing
- Compliance with HIPAA, GDPR, and other relevant regulations
- Secure coding practices and dependency management
- Regular backup and disaster recovery procedures

## Compliance

This system is designed to comply with:
- **HIPAA** (Health Insurance Portability and Accountability Act)
- **GDPR** (General Data Protection Regulation)
- **HITECH** (Health Information Technology for Economic and Clinical Health Act)
- **State-specific healthcare privacy laws**


CONTRACT ADDRESS : 0xa460FC9fee404671be62c835d1aa4384EA9Dfc9A

![alt text](image.png)  

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Healthcare interoperability standards (HL7 FHIR)
- Open source healthcare community
- Privacy and security research contributions

---

**Note**: This is a healthcare application handling sensitive medical data. Ensure proper security measures, compliance requirements, and legal considerations are addressed before deploying to production.
