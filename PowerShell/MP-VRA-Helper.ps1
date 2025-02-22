Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Override Browser (Set to "chrome", "firefox", "edge", or leave empty for default browser)
$global:browser = "firefox"

# Initialize global variables
$global:currentStep = 0
$global:productName = ""  # Default empty value for product name
$global:productURL = ""  # Default empty value for product name

# Define a list of search actions as a set of templates.
$stepTemplates = @(
    @{ 
        SectionLabel = 'Description of Vendor';
        SectionText = 'Search for description of what "$productName" is/does/provides' ;
        SearchPattern = 'what is "$productName"';
        CustomURL = $null 
    },
    @{ 
        SectionLabel = 'Type of Service Implementation';
        SectionText = 'Search for if "$productName" is cloud based';
        SearchPattern = 'is "$productName" cloud based';
        CustomURL = $null 
    },
    @{ 
        SectionLabel = 'Type of Service Implementation';
        SectionText = 'Search for if "$productName" is subscription only';
        SearchPattern = 'is "$productName" subscription only';
        CustomURL = $null 
    }, 
    @{ 
        SectionLabel = 'General Internet Search';
        SectionText = 'Search for "$productName + litigation, lawsuit, vulnerability"';
        SearchPattern = '"$productName" AND ("litigation" OR "lawsuit" OR vulnerability)';
        CustomURL = $null 
    },
    @{ 
        SectionLabel = 'Evidence of Past Breaches';
        SectionText = 'Search for "$productName + breach"';
        SearchPattern = '"$productName" AND "breach"';
        CustomURL = $null 
    },
    @{ 
        SectionLabel = "California Attorney General's website";
        SectionText = 'Search for "$productName" in Attorney Generals website';
        SearchPattern = '';
        CustomURL = 'https://oag.ca.gov/privacy/databreach/list?field_sb24_org_name_value=$productName' 
    },
    @{ 
        SectionLabel = 'FedRAMP Marketplace';
        SectionText = 'Search for "$productName" on FedRAMP. Note: Scroll down to type name in "Search Marketplace" section. ';
        SearchPattern = '';
        CustomURL = 'https://marketplace.fedramp.gov/products' 
    },
    @{ 
        SectionLabel = "Vendor's Website";
        SectionText = 'Search for "$productName" main website, if it is not "$productURL"';
        SearchPattern = '"$productName" main website';
        CustomURL = $null 
    },
    @{ 
        SectionLabel = "Vendor's Website";
        SectionText = 'Search for "$productName" security section. Note: Do not use Privacy Policy.';
        SearchPattern = '"$productName" security page';
        CustomURL = $null 
    },
    @{ 
        SectionLabel = "Vendor's Website";
        SectionText = 'Search for "$productName" Public Notification section';
        SearchPattern = '"$productName" AND ("release notes" OR "blog" or "notices")';
        CustomURL = $null 
    },
    @{ 
        SectionLabel = "Vendor's Website";
        SectionText = 'Search for "$productName" headquarters';
        SearchPattern = 'where is "$productName" headquarters';
        CustomURL = $null 
    },
    @{ 
        SectionLabel = "Vendor's Website";
        SectionText = 'Search for "$productName" other offices';
        SearchPattern = 'where are other "$productName" offices';
        CustomURL = $null 
    },
    @{ 
        SectionLabel = "Vendor's Website";
        SectionText = 'Search for "$productName" employee locations';
        SearchPattern = 'where are most "$productName" employees located';
        CustomURL = $null 
    },
    @{ 
        SectionLabel = 'Qualys SSL Labs Scan';
        SectionText = 'Search for "$productURL" on SSL Labs Scan';
        SearchPattern = '';
        CustomURL = 'https://www.ssllabs.com/ssltest/analyze.html?d=$productURL' 
    },
    @{ 
        SectionLabel = 'Bug Bounty';
        SectionText = 'Search for "$productURL" on Bug Bounty';
        SearchPattern = '';
        CustomURL = 'https://www.openbugbounty.org/search/?search=$productURL' 
    },
    @{ 
        SectionLabel = 'CVE Details on Vendor and Service/Product';
        SectionText = 'Search for "$productName" on CVE Details. Note: Use the serchbar at the top of page.';
        SearchPattern = '';
        CustomURL = 'https://www.cvedetails.com/' 
    },
    @{ 
        SectionLabel = 'Prohibited Services/Products/Use';
        SectionText = 'Search for "$productName + prohibited"';
        SearchPattern = '"$productName" AND (prohibited)';
        CustomURL = $null 
    },
    @{ 
        SectionLabel = 'Prohibited Services/Products/Use';
        SectionText = 'Search for "$productName + Kaspersky"';
        SearchPattern = '"$productName" AND "kaspersky"';
        CustomURL = $null 
    },
    @{ 
        SectionLabel = 'Open Source Vulnerability (OSV) Database';
        SectionText = 'Search for "$productName" in Open Source Vulnerability (OSV) Database';
        SearchPattern = '';
        CustomURL = 'https://osv.dev/list?q=$productName'; 
    },
    @{ 
        SectionLabel = 'Third-party Evaluation(s)';
        SectionText = 'Search for "$productName" or "$productURL" on BitSight';
        SearchPattern = '';
        CustomURL = "https://service.bitsighttech.com/sso/university-of-california-davis-1:UCD/" 
    },
    @{ 
        SectionLabel = 'MOVEit vulnerability';
        SectionText = 'Search for "$productName + MOVEit"';
        SearchPattern = '"$productName" AND "MOVEit"';
        CustomURL = $null 
    }
)

# Function to generate steps based on the templates
function Get-Steps {
    param (
        [string]$productName,
        [string]$productURL
    )

    $steps = @()
    
    # Generate each step dynamically based on the template
    for ($i = 0; $i -lt $stepTemplates.Count; $i++) {
        $step = $stepTemplates[$i]
        
        # Replace $productName and $productURL in each template
        $stepText = $step.SectionText -replace '\$productName', $productName -replace '\$productURL', $productURL
        $stepQuery = $step.SearchPattern -replace '\$productName', $productName -replace '\$productURL', $productURL
        $stepURL = $step.CustomURL -replace '\$productName', $productName -replace '\$productURL', $productURL

        $steps += @{
            #Text = "Step $($i + 1): $stepText"  #To add step number
            SectionLabel = $step.SectionLabel
            Text = $stepText
            SearchQuery = $stepQuery
            CustomURL = $stepURL
        }
    }

    return $steps
}

# Initialize steps for the first time
$global:steps = Get-Steps -productName $global:productName -productURL $global:productURL

# Function to Update UI State
function Update-StepUI {
    # Update SectionLabel with the current step's label
    $sectionLabel.Text = $global:steps[$global:currentStep].SectionLabel

    # Update the main step text
    $label.Text = $global:steps[$global:currentStep].Text

    # Enable/Disable navigation buttons
    $backButton.Enabled = $global:currentStep -gt 0
    $nextButton.Enabled = $global:currentStep -lt ($global:steps.Count - 1)
}

# Create the Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Multi-point VRA"
$form.Size = New-Object System.Drawing.Size(450, 250)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true

# Create a label and textbox for product name input
$productNameLabel = New-Object System.Windows.Forms.Label
$productNameLabel.Text = "Enter product name:"
$productNameLabel.Size = New-Object System.Drawing.Size(200, 20)
$productNameLabel.Location = New-Object System.Drawing.Point(25, 5)  # Positioned above the textbox
$form.Controls.Add($productNameLabel)

$productNameTextBox = New-Object System.Windows.Forms.TextBox
$productNameTextBox.Size = New-Object System.Drawing.Size(150, 20)
$productNameTextBox.Location = New-Object System.Drawing.Point(25, 25)  # Positioned at upper left
$productNameTextBox.Add_TextChanged({
    # Update the global product name whenever the text changes
    $global:productName = $productNameTextBox.Text
    # Generate steps based on the updated product name
    $global:steps = Get-Steps -productName $global:productName -productURL $global:productURL
    # Update the label and step information dynamically
    Update-StepUI
})
$form.Controls.Add($productNameTextBox)

# Create a label and textbox for product url input
$productURLLabel = New-Object System.Windows.Forms.Label
$productURLLabel.Text = "Enter product URL:"
$productURLLabel.Size = New-Object System.Drawing.Size(200, 20)
$productURLLabel.Location = New-Object System.Drawing.Point(225, 5)  # Positioned above the textbox
$form.Controls.Add($productURLLabel)

$productURLTextBox = New-Object System.Windows.Forms.TextBox
$productURLTextBox.Size = New-Object System.Drawing.Size(150, 20)
$productURLTextBox.Location = New-Object System.Drawing.Point(225, 25)  # Positioned at upper left
$productURLTextBox.Add_TextChanged({
    # Update the global product name whenever the text changes
    $global:productURL = $productURLTextBox.Text
    # Generate steps based on the updated product name
    $global:steps = Get-Steps -productName $global:productName -productURL $global:productURL
    # Update the label and step information dynamically
    Update-StepUI
})
$form.Controls.Add($productURLTextBox)

# Create the Label for SectionLabel (centered above step text)
$sectionLabel = New-Object System.Windows.Forms.Label
$sectionLabel.Size = New-Object System.Drawing.Size(400, 30)  # Adjusted size for description text
$sectionLabel.Location = New-Object System.Drawing.Point(25, 60)  # Positioned above the SectionText label
$sectionLabel.TextAlign = "MiddleCenter"  # Center align the text
$sectionLabel.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($sectionLabel)

# Create the Label for step text (centered)
$label = New-Object System.Windows.Forms.Label
$label.Size = New-Object System.Drawing.Size(400, 50)
$label.Location = New-Object System.Drawing.Point(25, 90)  # Adjusted to leave space for TextBox
$label.TextAlign = "MiddleCenter"
$label.Font = New-Object System.Drawing.Font("Arial", 12)
$form.Controls.Add($label)

# Create the Back Button
$backButton = New-Object System.Windows.Forms.Button
$backButton.Text = "Back"
$backButton.Size = New-Object System.Drawing.Size(75, 30)
$backButton.Location = New-Object System.Drawing.Point(25, 170)  # Adjusted for bottom placement
$backButton.Enabled = $false
$backButton.Add_Click({
    # Decrease the current step and update UI
    if ($global:currentStep -gt 0) {
        $global:currentStep--
        Update-StepUI
    }
})
$form.Controls.Add($backButton)

# Create the Next Button
$nextButton = New-Object System.Windows.Forms.Button
$nextButton.Text = "Next"
$nextButton.Size = New-Object System.Drawing.Size(75, 30)
$nextButton.Location = New-Object System.Drawing.Point(125, 170)  # Adjusted for bottom placement
$nextButton.Enabled = $true
$nextButton.Add_Click({
    # Increase the current step and update UI
    if ($global:currentStep -lt ($global:steps.Count - 1)) {
        $global:currentStep++
        Update-StepUI
    }
})
$form.Controls.Add($nextButton)

# Create the Search Button
$searchButton = New-Object System.Windows.Forms.Button
$searchButton.Text = "Search"
$searchButton.Size = New-Object System.Drawing.Size(75, 30)
$searchButton.Location = New-Object System.Drawing.Point(225, 170)  # Adjusted for centered placement
$searchButton.Add_Click({
    # Access the correct current step and search query
    $query = $global:steps[$global:currentStep].SearchQuery
    $customURL = $global:steps[$global:currentStep].CustomURL

    if ($customURL) {

        # Check the specified browser and open the URL accordingly
        switch ($global:browser.ToLower()) {
            "chrome" {
                Start-Process "chrome.exe" -ArgumentList $customURL
            }
            "firefox" {
                Start-Process "firefox.exe" -ArgumentList $customURL
            }
            "edge" {
                Start-Process "msedge.exe" -ArgumentList $customURL
            }
            default {
                Start-Process $customURL
            }
        }
    }

    elseif ($query) {
        # If no custom URL is provided, search using Google
        $encodedQuery = [System.Uri]::EscapeDataString($query)

        # Check the specified browser and open the URL accordingly
        switch ($global:browser.ToLower()) {
            "chrome" {
                Start-Process "chrome.exe" -ArgumentList "https://www.google.com/search?q=$encodedQuery"
            }
            "firefox" {
                Start-Process "firefox.exe" -ArgumentList "https://www.google.com/search?q=$encodedQuery"
            }
            "edge" {
                Start-Process "msedge.exe" -ArgumentList "https://www.google.com/search?q=$encodedQuery"
            }
            default {
                Start-Process "https://www.google.com/search?q=$encodedQuery"
            }
        }
    }
})
$form.Controls.Add($searchButton)

# Create the Exit Button
$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Text = "Exit"
$exitButton.Size = New-Object System.Drawing.Size(75, 30)
$exitButton.Location = New-Object System.Drawing.Point(325, 170)  # Adjusted to align with the buttons
$exitButton.Add_Click({
    $form.Close()
})
$form.Controls.Add($exitButton)

# Show the Form
Update-StepUI
[void]$form.ShowDialog()