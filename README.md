# SQM_Installer
Installer for updates to SQM

**Your queries should remain intact and untouched but it's preferred to save your queries before installing. **
----------------------------------------------------------------------------------------------------------
## Usage

### Managing Queries

- To create a new query, click the "Create New Query" button and provide a name and template.
- To edit an existing query, select it from the list and click "Edit Query".
- Use the search box to quickly find specific queries. **(Ctrl + F)**
- Use the "Backup Queries" feature to save a zip file of all your saved queries.
- Check out the query history folder. This folder is updated with in a "before and after" snapshot of the individual query you have edited and saved. These files can be removed as needed

### Populating Queries

1. Fill in the relevant patient data fields on the left side of the interface. **(Ctrl + Shift + Space) to get all data from the customer request. See "Parse All"**
2. Select a query from the list on the right.
3. Click "Populate Query" to insert the data into the selected query template. **(Ctrl + Enter)**
4. The populated query will appear in the bottom right text area, ready to be copied and executed. Once "populate query" runs, the populated query is automatically copied to your clipboard, but there's also a button there.

### Parsing Data

- Use the "Parse Dates", "Parse pt. Data" (MR Numbers), "Parse Epi", and "Parse Orders" buttons to automatically extract information from the notepad text.
- The "Parse All" button will attempt to extract all types of data at once. (This will also include patientIDs. **(Ctrl + Shift + Space)**

### Generating Statements

1. Go to Advanced > Generate Statements in the menu bar.
2. Select the type of statement you want to generate.
3. Paste the relevant input data into the dialog box.
4. Click OK to generate the statement, which will appear in the populated query area.

## Customization

- Custom fields can be added or removed by editing the `custom_fields_order.json` file and the text files in custom_fields folder containing the respective custom field names. Both need to be updated. Here you can change how the custom fields names appear as well. Chaning the custom fields names is what changes the placeholder names.
  Example: episode_id custom field name = {episode_id} placeholder
           Changig "episode_id" to "epi_id" will change the placeholder to {epi_id} etc.
           Again, make sure you update both files--the json and the corresponding text file in custom_fields folder.
- The order the custom fields appear in can be adjusted by changing the order they appear from top>bottom in the .json file.
- Custom parsing patterns can be defined in the `custom_patterns.json` file. This is used to update the language customers use to define how an episodeID is parsed as well as orderIDs. Follow the json format by adding a comma after the last row (whether episodeID or orderID) enclosed in double quotes. Most formats have already been accounted for.

## Troubleshooting

- If you encounter any issues, check the `sql_query_manager.log` file for error messages. Most errors are self-explanitory and usually have to do with syntax of the saved query. In other words, there's a placeholder typed incorrectly there.
- Ensure all required JSON files (`custom_fields_order.json`, `custom_patterns.json`, `name_parsing_rules.json`, `statement_generators.json`) are present in the application directory.

## Contributing

Happy to hear from you regarding any enhacements you might have.
