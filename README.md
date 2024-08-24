# SQM_Installer
Installer for updates to SQM

**Your queries should remain intact and untouched but it's preferred to save your queries before installing an update.**
----------------------------------------------------------------------------------------------------------
## Usage

### Managing Queries

- To create a new query, click the "Create New Query" button and provide a name and template.
- To edit an existing query, select it from the list and click "Edit Query".
- Use the search box to quickly find specific queries. **(Ctrl + F)**
- Use the "Backup Queries" feature to save a zip file of all your saved queries.
- Check out the query history folder. This folder is updated with a "before and after" snapshot of the individual query you have edited and saved. These files can be removed as needed

### Populating Queries

1. Fill in the relevant patient data fields (Patient Data Management--**PDM**) on the left side of the interface. **(Ctrl + Shift + Space) to get all data from the customer request. See "Parse All"**
2. Select a query from the list on the right.
3. Click "Populate Query" to insert the data into the selected query template. **(Ctrl + Enter)**
4. The populated query will appear in the bottom right text area, ready to be copied and executed. Once "populate query" runs, the populated query is automatically copied to your clipboard, but there's also a button there.

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


## Troubleshooting

- If you encounter any issues, check the `sql_query_manager.log` file for error messages. Most errors are self-explanitory and usually have to do with syntax of the saved query. In other words, there's a placeholder typed incorrectly there.
- Ensure all required JSON files (`custom_fields_order.json`, `custom_patterns.json`, `name_parsing_rules.json`, `statement_generators.json`) are present in the application directory.

## Contributing

Happy to hear from you regarding any enhacements you might have.
