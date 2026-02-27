# ScanWise Feature Architecture Standard

Every feature must follow Clean Architecture:

feature_name/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
└── presentation/
├── pages/
├── widgets/
└── providers/

Rules:
- No Flutter imports inside domain
- Repository interface in domain
- Repository implementation in data
- UI only inside presentation