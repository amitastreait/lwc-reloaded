# Salesforce Scratch Orgs

## What is a Scratch Org?

- **Definition**: A disposable Salesforce environment that can be quickly created and destroyed
- **Purpose**: Built for development, testing, and automation
- **Nature**: Lightweight, ephemeral deployment of Salesforce code and metadata
- **Lifespan**: Short-lived (1-30 days by default)
- **Management**: Created and managed through Salesforce(sf) CLI (Developer Experience) tools

---

## Key Characteristics

- **Source-driven**: Configured entirely from source code
- **Automated**: Can be created through CLI commands and scripts
- **Isolated**: Provides clean testing environments
- **Customizable**: Features can be enabled/disabled based on needs
- **Reproducible**: Created from definition files for consistent environments

---

## Setting Up a Scratch Org

1. **Prerequisites**:
   - Salesforce CLI installed
   - Dev Hub org enabled
   - Connected to Dev Hub

2. **Basic Creation Process**:
   ```python
   sf org create scratch --target-dev-hub lwc-reloaded --definition-file config/project-scratch-def.json --set-default --duration-days 30 --wait 10
   ```

3. **Configuration File** (project-scratch-def.json):
   ```json
    {
        "orgName": "PantherSchools Company",
        "edition": "Enterprise",
        "hasSampleData": true,
        "features": [
            "EnableSetPasswordInApi"
         ],
        "settings": {
            "lightningExperienceSettings": {
               "enableS1DesktopEnabled": true
            },
            "mobileSettings": {
               "enableS1EncryptedStoragePref2": false
            }
        }
    }
   ```
---
## Scratch Org Definition File Options

- **Edition**: Developer, Enterprise, Group, Professional, etc.
- **Features**: Einstein, Communities, ServiceCloud, etc.
- **Settings**: Enable/disable specific Salesforce settings
- **Org Preferences**: Configure org behavior
- **Username**: Define username format

---

## Core Benefits

1. **Accelerated Development**
   - Rapid creation of clean environments
   - No administrative overhead
   - Quick iteration cycles

2. **Improved Quality**
   - Isolated testing environments
   - Reproducible conditions
   - Automated testing capabilities

3. **Enhanced Collaboration**
   - Consistent dev environments across team
   - Easy onboarding of new developers
   - Environment parity with shared configuration

---

## Use Cases for Scratch Orgs

- **Feature Development**: Isolated environment for new features
- **Bug Fixing**: Reproduce and fix issues in clean state
- **Automated Testing**: CI/CD pipelines with fresh orgs
- **Demos & POCs**: Quick setup for demonstrations
- **Training**: Consistent environments for team training
- **Package Development**: Test managed/unmanaged packages

---

## Scratch Orgs vs. Sandboxes

| Feature | Scratch Orgs | Sandboxes |
|---------|-------------|-----------|
| Creation | Minutes (CLI) | Hours (UI/API) |
| Source | Empty + config | Copy of production |
| Lifespan | 1-30 days | Months/Permanent |
| Cost | Free (with Dev Hub) | Depends on type |
| Creation limit | 100/day (Enterprise) | Limited by edition |
| Purpose | Development/Testing | Integration/UAT |
| Data | Sample/imported | Copied/masked |

---

## Scratch Orgs in the Development Lifecycle

```
┌─────────────────┐     ┌────────────────┐     ┌──────────────┐
│ Create Scratch  │     │ Develop &      │     │ Test &       │
│ Org from Source │ ──> │ Push Changes   │ ──> │ Validate     │
└─────────────────┘     └────────────────┘     └──────────────┘
         │                                             │
         │                                             ▼
┌─────────────────┐     ┌────────────────┐     ┌──────────────┐
│ Delete Scratch  │ <── │ Pull Changes   │ <── │ Automate     │
│ Org When Done   │     │ to Source      │     │ with CI/CD   │
└─────────────────┘     └────────────────┘     └──────────────┘
```
---

## Best Practices

- **Version Control**: Commit scratch org definition files
- **Scripting**: Automate org creation and setup
- **Data**: Create data generation scripts for testing
- **Documentation**: Document org configuration needs
- **Templates**: Create standard templates for common use cases
- **Cleanup**: Regularly delete unused scratch orgs

---

## Common Challenges & Solutions

**Challenge**: Scratch orgs expire quickly
**Solution**: Automate creation or extend duration (max 30 days)

**Challenge**: Feature limitations
**Solution**: Carefully review available features in definition file

**Challenge**: Performance during initial setup
**Solution**: Create scripts to automate repetitive setup tasks

---

## Integration with Modern DevOps

- **CI/CD Pipelines**: Automated testing in fresh environments
- **Version Control Systems**: Git integration for source tracking
- **IDEs**: VS Code and Salesforce extensions
- **Package Development**: Test packages in isolated environments
- **Cross-team Collaboration**: Consistent environments for all developers

---

## Summary: Why Use Scratch Orgs?

- **Speed**: Rapidly create clean environments
- **Quality**: Ensure consistent testing conditions
- **Automation**: Script creation and configuration
- **Collaboration**: Standardize development environments
- **Modern**: Align with DevOps best practices
- **Cost-effective**: Free with Dev Hub enabled

---

## Additional Resources

- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Scratch Org Configuration Values](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_def_file_config_values.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
- [Trailhead: Quick Start: Salesforce DX](https://trailhead.salesforce.com/en/content/learn/projects/quick-start-salesforce-dx)