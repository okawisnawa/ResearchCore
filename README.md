# ResearchCore 🚀
**Enterprise-Grade Research Infrastructure & Lab Orchestration**

---

## 📖 Overview
**ResearchCore** is a robust, reproducible research environment orchestration system designed for high-performance computing on RHEL-based workstations. Leveraging **Distrobox** and **OCI containers**, this infrastructure ensures total isolation between research domains while maintaining seamless integration with the host system.

Built for **Autonomous Systems, Robotics (ROS2), Computer Vision, and Cyber Forensics.**

---

## 🛠 Architecture v4.0
The system utilizes a "Rootless-First" design to ensure maximum host security while providing dedicated, containerized workspaces.

### Laboratory Specifications
| Lab Name | Base Image | Purpose |
| :--- | :--- | :--- |
| `autonomous-lab` | `ubuntu:24.04` | Autonomous Systems & GPU-accelerated CV |
| `datamining-lab` | `ubuntu:24.04` | Data Analysis & Model Training |
| `mobile-dev` | `ubuntu:24.04` | Mobile Application Development |
| `forensic-lab` | `kali-rolling` | Cyber Security & Forensic Analysis |

---

## ⚡ Quick Start

### Prerequisites
- [Podman](https://podman.io/) or Docker installed.
- [Distrobox](https://distrobox.it/) installed.
- SSH Key configured for secure remote synchronization.

### Deployment
1. **Clone the repository:**
   ```bash
   git clone git@github.com:okawisnawa/ResearchCore.git
   cd ResearchCore
