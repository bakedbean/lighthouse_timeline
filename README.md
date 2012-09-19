Lighthouse Visualizer
====================

A Sinatra application that uses the Lighthouse Ruby API
-------------------------------------------------------

A simple application that fetches tickets based on state and tag, and displays along a visual timeline for easy reference and project management.

### INSTALL
`git clone git@github.com:bakedbean/lighthouse_timeline.git`  
`cd lighthouse_timeline`  
`bundle install`

### INSTRUCTIONS

From the source directory: `shotgun config.ru`  
From a web browser: `http://localhost:9393`

### CUSTOMIZATIONS

Includes an object for connecting to the Google Docs API
Connects to a Berklee.edu specific spreadsheet
Adds ticket data to a priority worksheet for support management
