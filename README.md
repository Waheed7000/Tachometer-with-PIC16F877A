# Tachometer-with-PIC16F877A

This project implements a **tachometer** system using the **PIC16F877A microcontroller** to measure and monitor the RPM (revolutions per minute) of a DC motor with high accuracy. The RPM is displayed on a 16x2 LCD and transmitted via **UART protocol** to an Android application built using **MIT App Inventor**.

In addition to real-time monitoring, users can remotely:
- **Start/stop the motor**
- **Control its speed** via PWM using either a physical **potentiometer** or the mobile application.

> 📌 **Accuracy:** The system provides highly reliable readings with a typical error margin of less than ±3 RPM, ensuring stable and consistent measurements.

---

## 🔩 Components Used

> `(*)` = essential components

- `*` PIC16F877A Microcontroller  
- `*` 8MHz Crystal Oscillator  
- `*` HC-05 Bluetooth Module  
- `*` Two Li-ion 18650 Battery Cells (3.7V each, total 7.4V)  
- Battery Holder (2×18650)  
- Switch ON/OFF  
- `*` L298N Motor Driver Module  
- `*` 16x2 LCD Display  
- `*` DC Geared Motor (TT Motor / Yellow Motor)  
- `*` Photoelectric Encoder  
- `*` Encoder Disk (with 20 slotted & 20 solid segments)  
- Large / Medium / Small Breadboards  
- `*` Two 10K Potentiometers  
- `*` Two Push Buttons  
- `*` 7805 Voltage Regulator  
- Heatsink for Voltage Regulator  
- `*` 1N5819 Schottky Diode  
- `*` Five 100nF Ceramic Capacitors  
- `*` Two 100μF Electrolytic Capacitors  
- `*` Two 22pF Ceramic Capacitors  
- 470μF Capacitors  
- 10μF Capacitors  
- `*` Multiple Resistors: 10K, 1.8K, 1.3K, 150Ω  
- `*` Plenty of Jumper Wires 
<br>
  <img src="images/TT_Motor.jpg" width="200" />

- 📷 Geared Motor Photo
<br>
  <img src="images/Photoelectric_encoder.jpg" width="200" />

- 📷 Photoelectric encoder Photo
<br>
<img src="images/Encoder_disk.jpg" width="200" />

- 📷 Encoder Disk Photo

---

## 📷 Project Images

<img src="images/Tachometer.jpg" width="400" />

---

## 📱 Mobile App

- Built using **MIT App Inventor**
- Connects to the microcontroller via Bluetooth
- Displays real-time RPM
- Allows full remote control (start/stop/speed)
- Includes `.apk` file for installation

<br>
<img src="images/Bloks1.jpg" width="650" /> 
<img src="images/Bloks2.jpg" width="650" />
<img src="images/Bloks3.jpg" width="650" />

- 📷 MIT app inventor Bloks 


<br>
<img src="images/screenshot.jpg" style="max-width: 100%; height: auto;"/>

- 📷 Screenshot from the app

---

## 🧠 How It Works

The system uses an IR encoder sensor to count how many solid segments of the encoder disk pass in a time period **T**, then applies the following formula:

RPM = (Number of pulses detected in T / T) × (60 / N)

Where:
- `T` = measurement window in seconds
- `N` = number of solid segments on the encoder disk (in this case: 20)

---

## 🧾 Included Files

| File / Folder | Description |
|---------------|-------------|
| `code/tachometer src` | Source code for the PIC (in MikroC) |
| `app` | `.apk` for Android app |
| `images/images` | Project photos, schematic, screenshots |
| `schematic` | Project schematic daigram using proteus  |
| `README.md` | Project documentation |
| `LICENSE` | MIT License |
| `*.hex/tachometer src` | Compiled firmware |

---

## ⚠️ Notes for Replication

- Make sure to add a **voltage divider** (using 1.8K and 1.3K resistors) on the RX pin of the Bluetooth module to avoid damaging it.
- It is recommended to install a **heatsink** on the 7805 voltage regulator.
- Ensure **proper capacitor values** are used around the regulator for power stability.
- Double-check the orientation of all polarized components (diodes, electrolytic capacitors, etc.)

---

## License

This project is released under the [MIT License](LICENSE) — feel free to use, modify, and share with proper attribution.

---