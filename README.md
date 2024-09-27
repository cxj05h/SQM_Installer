# SQM_Installer
Installer for updates to SQM

**Your queries, service codes list, custom patterns and custom fields order should remain intact and untouched but _it's preferred to save your queries_ before installing an update.**
----------------------------------------------------------------------------------------------------------
## Usage

### Managing Queries

- To create a new query, click the "Create New Query" button and provide a name and template.
- To edit an existing query, select it from the list and click "Edit Query".
- Use the search box to quickly find specific queries. **(Ctrl + F)**
- Use the "Backup Queries" feature to save a zip file of all your saved queries.
- Check out the query history folder if you made a change to an existing query and you need to revert or check what change you made. This folder is updated with a "before and after" snapshot of the individual query you have edited and saved. These files can be removed as needed

### Populating Queries

1. Fill in the relevant patient data fields (Patient Data Management--**PDM**) on the left side of the interface. **(Ctrl + Shift + Space) to get all data from the customer request you've pasted in the Notepad to populate PDM. See "Parse All"**
2. Select a query from the list on the right.
3. Click "Populate Query" to insert the data into the selected query template. **(Ctrl + Enter)**
4. The populated query will appear in the bottom right text area, ready to be copied and executed. Once "populate query" runs, the populated query is automatically copied to your clipboard, but there's also a button "Copy Query for SSMS" .

### Parsing Data

- Use the "Parse Dates", "Parse pt. Data" (MR Numbers), "Parse Epi", and "Parse Orders" & "Parse Service Code" buttons to automatically extract information from the notepad text.
- The "Parse All" button will attempt to extract all types of data at once. (This will also include patientIDs. **(Ctrl + Shift + Space)**
- The button "Convert Names" will take a patient name from the notepad field and place it into the "Multiple Names" custom field where it will be formatted correctly to be parsed into the {names_clause} placeholder. You will need to highlight the name first and then hit the button "Convert Nmes". It will take Firstname Lastname and convert it into Lastname, Firstname MI. If you highlight multiple names, they will all be formated as mentioned but separated by a |. This is how the {names_clause} reads multiple names.
    - To use {names_clause} in a query, place it after 'WHERE'
      #### Example for how to write it in a saved query:
        *SELECT epi_lastname, epi_firstname, epi_mi, epi_id from client_episodes_all WHERE {names_clause}*
      
- If a customer just provides a bunch of numbers, whether it's episode IDs or order IDs and it's not simple to just highlight them all, you can also go to Advanced > Parse Orders/Parse Episodes and there you'll receive a dialog box with a number. That number is the number of characters it will parse for. For example, typically order IDs are 6-7 digits so you can select "Parse Orders" choose the digit count (you can hover over the field and use the mouse wheel to scroll up and down to select the number) and hit parse. If you don't have Stephan's AHK script for comma-separated pastes, this is the best, really.
- Most requests have multiple dates and service codes in the text. When you "Parse Service Code" or "Parse Dates" (also included in "Parse All"), a dialog box will appear for you to select which dates and service codes you want populated into PDM. Dates will always appear in the {Date} custom field, and service codes always in the {Service_Code} field.
    - When the box appears, hitting "**Enter**" once will load all the dates available and hitting it again will select "Ok". This applies to both SC and Dates. Hitting **'Esc'** will abort that dialog box.

### Generating Statements

1. Go to Advanced > Generate Statements in the menu bar.
2. Select the type of statement you want to generate.
3. Paste the relevant input data into the dialog box.
4. Click OK to generate the statement, which will appear in the populated query area.

## Customization

- Custom fields can be added or removed by editing the `custom_fields_order.json` file and the text files in custom_fields folder containing the respective custom field names. Both need to be updated. Here you can change how the custom fields names appear as well. Chaning the custom fields names is what changes the placeholder names.
  - Example: episode_id custom field name = {episode_id} placeholder
    - Changing "CaseNum" to "Case#" will change the placeholder to {Case#} etc.
    - Again, make sure you update both files--the json and the corresponding text file in custom_fields folder.
- Patient, Episode, Order and MRnum are all hardcoded into SQM and _cannot be changed_, **only the order**.
- The order the custom fields appear in can be adjusted by changing the order they appear from top>bottom in the .json file.
- Custom parsing patterns can be defined in the `custom_patterns.json` file. This is used to update the language customers use to define how an episodeID is parsed as well as orderIDs. Follow the json format by adding a comma after the last row (whether episodeID or orderID) enclosed in double quotes. Most formats have already been accounted for.

## Parsing and Populating Dates for Multiple Fields

As of v1.1.3, you can now preface any custom field/placeholder to flag it as a 'date' data type. This means any date found in the Notepad field is eligible for parsing in multiple fields. Which fields they slot into depend on the saved query you have selected. Within your saved query, if you want to use any other custom field (besides {Date}) as a date type, you just need to add '@' before to the right side of the first curly bracket, before the start of the custom field name. This signifies to SQM that you want this to act as a date. When 'Populate Query' runs, it will automatically add single quotes to that placeholder. Only one date per field (besides {Date} is allowed in the "borrowed" custom fields being used as dates. 

When multiple dates are found in the Notepad, you will get a dialog box accompanied by the Guidance Text you've used in that saved query asking you which date you want for that custom field. See below for how to incoroporate the guidance text.

## Guidance Text

Guidance text is used to help you customize the custom fields names. Not each query you use will use the hardcoded names, so you'll want extra text to suite each query.

For example, if you want to use the {Service_Code} custom field as a placeholder for a 'wkr_lastname' - you want this to be clear when you select the query. 

For this, you'll want to add Guidance Text at very top of your saved query (make sure it's using the first line of the saved query only!). you'll need to write out the following in the exact way in order for SQM to recognize the guidance text:

Example using {episode_id} as the placeholder you want to modify:
GUIDANCE:{episode_id}`/*this is the guidance text*/`

### Use 'Guidance Text' to add text to the Patient Data Management screen as well as the Date Selector prompts. 

Example of guidance text at the top of a saved query to reference which dates are for what part of the query: 

GUIDANCE:{@Service_Code}`/*New visit date*/`,GUIDANCE:{@EventID}`/*SOC Date*/`

## Image to text
- Drag customer's image to the plain text box and wait for it to be converted to text. May not work with all images. Should be JPEG, PNG or BMP. You might need to take a screenshot of their image to easily reformat the image and also exclude problematic parts of the image which won't convert well. Works best with screenshots of reports or spreadsheets.


## Troubleshooting

- If you encounter any issues, check the `sql_query_manager.tct` file (C:\Users\AppData\Local\SQL Query Manager) for error messages. Most errors are self-explanitory and usually have to do with syntax of the saved query. In other words, there's a placeholder typed incorrectly there.
- Ensure all required JSON files (`custom_fields_order.json`, `custom_patterns.json`, `name_parsing_rules.json`, `statement_generators.json`) are present in the application directory (C:\Users\AppData\Local\Programs\SQL Query Manager).

## Updates
- If an update is available, you will be prompted upron running the app. **As for now forlders: Custom_fields_order, Custom_patterns, Name_parsing_rules, Service_Codes will all be REINSTALLED. If you have made any changes to these files, it's best to SAVE THEM/copy them to another location and drag/drop them back into the app folder AFTER NEW INSTALL (C:\Users\AppData\Local\Programs\SQL Query Manager) since after the update, they might be reverted to the intial install state.** 

## Contributing

Happy to hear from you regarding any enhacements you might have.
