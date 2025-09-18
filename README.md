# opensource-data

The **opensource-data** project is a GitHub Actions-based automation tool responsible for generating the `code.json` file used in the [NIST Open Source Portal](https://github.com/usnistgov/opensource). It relies on a custom, fixed version of the Code.gov-compatible scraper — `nist-software-scraper` — to fetch software metadata and produce a compliant software inventory.

---

## 🎯 Objective

To automate the generation and publication of the `code.json` inventory file, which is:

- Required for U.S. federal agencies per [Code.gov metadata standards](https://code.gov/about/compliance/inventory-code).
- Used in the NIST Open Source Portal for public transparency and technical searchability.

This repository works in parallel with [opensource-actions](https://github.com/usnistgov/opensource-actions) but focuses solely on data compliance and inventory generation.

---

## 🧱 Repository Structure
```plaintext
opensource-data/
├── .github/
│ └── workflows/
│ └── blank.yml # GitHub Action configuration (placeholder or trigger)
│
├── _action-update/
│ ├── Dockerfile # Container environment definition
│ ├── entrypoint.sh # Main scraping and transformation logic
│ └── hub-linux-amd64*.tgz # GitHub CLI (if required for API interaction)
│
└── README.md # Project documentation
```


---

## 🔁 How It Works

### 🔨 GitHub Action (Dockerized)

1. **Workflow Trigger** (from `.github/workflows/blank.yml` or external dispatcher):
   - Initiates a Docker container build.
2. **Inside the Container**:
   - Runs `entrypoint.sh`, which:
     - Calls the `nist-software-scraper` (installed or bundled)  
     - Fetches data from GitHub and/or Code.gov-compatible sources  
     - Produces a `code.json` file per schema v2.0
3. **Output**:
   - The generated `code.json` file is pushed to the portal repository or exported as an artifact.

### 🔗 Scraper Dependency

- The tool uses the [`nist-software-scraper`](https://github.com/usnistgov/nist-software-scraper):
  - A locked version of Code.gov’s inventory scraper
  - Ensures consistent, reproducible parsing and schema compliance

---

## 🧪 Local Testing

Clone this repo and run the container locally:

```bash
cd _action-update
docker build -t opensource-data .
docker run --rm -e GITHUB_TOKEN=your_token opensource-data
```

## ⚙️ Environment Variables
Set the following environment variables for authentication and filtering:
* GITHUB_TOKEN: required for private repo metadata access
* AGENCY: optional, specify the agency name for filtering
* OUTPUT_PATH: optional, override default code.json path

## 📤 Outputs
Upon execution, the action produces a code.json file, compliant with Code.gov's schema. This file includes metadata such as:
* Project names
* Licenses
* Contact information
* Descriptions
* Repository URLs
* Usage types (open-source, government-wide reuse, etc.)

## 📅 Automation Strategy
While blank.yml is a placeholder, you are encouraged to replace it or trigger the action via:
* Cron-based automation
* Manual workflow_dispatch
* External repository events (via repository_dispatch

## 📝 License
Released under Creative Commons Zero v1.0 Universal (CC0). Feel free to reuse and adapt.
