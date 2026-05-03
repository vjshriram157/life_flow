# Technical Documentation: Gemini Demand Forecaster

The **Gemini Demand Forecaster** is a predictive intelligence module within the LifeFlow Admin Dashboard designed to prevent blood shortages before they occur.

## 🧠 Core Functionality
It provides a **7-day predictive window** (Horizon) based on the last **30 days of platform activity** (Window). The system identifies which blood banks are at risk of running out of specific blood groups.

## ⚙️ How It Works (The Engine)

### 1. Data Aggregation
The system synchronizes with three major data streams in Firestore:
- **Appointment History**: Analyzes all `COMPLETED` donations to understand the frequency of donor arrivals.
- **Consumption Patterns**: Tracks how quickly different blood groups are being utilized by hospitals.
- **Live Inventory**: Pulls current units from the `blood_stock` collection.

### 2. The Predictive Model (Flux Velocity)
The backend service (`AdminDemandPredictionServlet.java`) applies a **Time-Series Velocity Model**:
- **Daily Average Flux**: Calculated as `Total Appointments (30 Days) / 30`. This represents the daily "velocity" of specialized blood group influx.
- **7-Day Forecast**: Multiplies the daily average by the 7-day horizon to predict upcoming demand.
- **Risk Delta**: Calculates `(Current Stock) - (Predicted 7-Day Demand)`.

### 3. Intelligence Mapping
The UI categorizes the results into three Intelligence states:
- 🔴 **CRITICAL (High Deficit)**: Predicted demand exceeds current stock. Triggers a red "Pulse" in the UI.
- 🟡 **MARGINAL (Watchlist)**: Supply is barely meeting demand.
- 🟢 **NOMINAL (Safe)**: Inventory levels are healthy for the current velocity.

## 🎨 Visual Intelligence UI
- **Supply Velocity Bars**: Real-time visual meters showing stock vs. predicted drain.
- **Confidence Matrix**: While currently a simulated confidence score based on data density, it represents the reliability of the local historical data.
- **Intelligence Aura**: High-fidelity dark-mode interface with experimental AI branding.

> [!NOTE]
> For the forecaster to be 100% accurate, historical data must be consistently recorded via the "Complete Appointment" flow in the Blood Bank dashboard.
