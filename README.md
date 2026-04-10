# ImageWarp
An advanced 9-point spline warping HLSL shader for ReShade, high-performance engineered for curved screen projector calibration. It features intuitive geometry controls, boundary markers, and a dynamic real-time grid.
Unlike standard linear warping tools, this shader utilizes Quadratic Spline Interpolation across a 3x3 mesh. This ensures a perfectly smooth image deformation without visible "folds" or sharp edges, making it the ideal solution for Sim-Racing, Flight Simulation, and professional Home Cinema setups.

![ReShade Version](https://img.shields.io/badge/ReShade-Compatible-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

## ✨ Key Features

- **9-Point Quadratic Spline Mesh**: Smooth, continuous curvature control across 9 strategic points.
- **Dynamic Calibration Grid**: A real-time grid anchored directly to the control markers. When you warp a point, the grid deforms with it for perfect physical alignment.
- **Red Boundary Detection**: The outer edges of the mesh are highlighted in red to help you perfectly match the physical borders of your screen.
- **Intuitive Cartesian Controls**: 
  - **X-axis**: Positive (+) moves Right, Negative (-) moves Left.
  - **Y-axis**: Positive (+) moves Up, Negative (-) moves Down.
- **Compact UI**: Control points are grouped as `float2` (X and Y on the same line) with `0.01` precision steps for ergonomic calibration.
- **Global Geometry Tools**:
  - **Global Translation (X, Y)**: Move the entire image without losing your warp settings.
  - **Global Zoom**: Scale the projection to fit your lens throw.
  - **Cylindrical Curvature (H/V)**: Apply global horizontal or vertical arcs before fine-tuning individual points.
  - **Center Linearity**: Adjust pixel density in the center of the screen.

## 🛠 Installation

1. Install [ReShade](https://reshade.me/) into your desired game or application.
2. Download `Warp_Pro_Projector.fx` from this repository.
3. Place the file into your ReShade shader folder (usually `reshade-shaders/Shaders/`).
4. Launch the game and enable `BarcoWarpPro` in the ReShade overlay.

## 🎯 Calibration Guide

1. **Enable the Tools**: Check `ACTIVATE CALIBRATION GRID` and `SHOW POINT MARKERS`.
2. **Align the Corners**: Use the 4 corner points (Top-Left, Top-Right, etc.) to align the **Red Lines** with the physical edges of your screen.
3. **Shape the Curves**: Use the center points (Top-Center, Bottom-Center, Left-Mid, Right-Mid) to compensate for the screen's curvature.
4. **Global Adjustments**: Use `Global Translation` and `Global Scale` to center the final result.
5. **Final Touch**: Use `Horizontal/Vertical Curvature` if your projector lens creates a global "smile" or "frown" effect.

## 📜 License

This project is licensed under the **MIT License**. You are free to use, modify, and distribute it.

---
*Developed for professional-grade simulator setups and curved projection environments.*
