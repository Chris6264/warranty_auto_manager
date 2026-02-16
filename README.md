# Warranty Auto Manager


<p align="center">
  <img width="500" height="600" alt="loginImage" src="https://github.com/user-attachments/assets/4a41feae-1097-43c6-9386-98247e06bd53" />
</p>

![Flutter](https://img.shields.io/badge/Flutter-Mobile%20App-02569B?logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Backend-FFCA28?logo=firebase&logoColor=black)
![Firestore](https://img.shields.io/badge/Firestore-Database-FF6F00?logo=firebase&logoColor=white)
![Storage](https://img.shields.io/badge/Firebase%20Storage-Images-FFA000?logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-Programming%20Language-0175C2?logo=dart&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Layered-purple)
![Pattern](https://img.shields.io/badge/Design-CRUD-blue)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)
![Status](https://img.shields.io/badge/Status-Initial%20Release-yellow)

---

## Project Background

**This project marks the beginning of my documented journey in mobile application development**, originally developed in 2024 and recently organized and published to GitHub as part of my professional portfolio.

Although it started as a learning project, it represents the foundation of my experience working with **Flutter and Firebase**, including CRUD architecture, cloud integration, and mobile UI design.

---

## Overview

**Warranty Auto Manager** is a mobile application developed with **Flutter** to manage and track **vehicle repair warranties** within an automotive workshop.

The application allows workshop staff to register vehicles using the **VIN (Vehicle Identification Number) as a unique identifier**, store a **photo of the vehicle**, manage records through full **CRUD operations**, and maintain a detailed history of **repairs associated with each vehicle**.

Users can also consult the **warranty status** of any repair performed on a vehicle.

---

## Technologies Used

### Frontend
- Flutter
- Dart

### Backend
- Firebase
  - Cloud Firestore (real-time database)
  - Firebase Storage (vehicle image storage)
  - Firebase Authentication (if enabled)

---

## Core Features

### Vehicle Management
- Register vehicles with:
  - VIN (unique key)
  - Vehicle photo
  - Basic vehicle information
- Edit vehicle data
- Delete vehicle records
- View vehicle details

### Repair Management
- Add repairs linked to a specific vehicle
- Edit repair information
- Delete repairs
- View full repair history per vehicle

### Warranty Tracking
- Check warranty status of each repair
- Track warranty duration
- Identify active or expired warranties

---

## Architecture

The application follows a layered separation between frontend and backend:

- Flutter handles UI, navigation, and state management.
- Firebase manages:
  - Structured data storage (Firestore)
  - Image storage (Firebase Storage)
  - Authentication (if enabled)

The project structure was designed with scalability in mind and serves as a foundational step in my mobile development journey.

---

## Purpose

This project was built to simplify warranty management in automotive workshops, reduce manual paperwork, and provide fast access to repair history and warranty validation.

It also marks the beginning of my documented software development portfolio.

