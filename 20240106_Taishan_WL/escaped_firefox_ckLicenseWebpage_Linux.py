import os
import re
import webbrowser
from datetime import datetime, timedelta

def days_until_target(date_str):
    """Calculate days from today to the target date."""
    target_date = datetime.strptime(date_str, "%d-%b-%Y")
    return (target_date - datetime.today()).days

def process_file(file_path):
    """Process the file and return results as a list of dictionaries."""
    results = []
    
    with open(file_path, 'r') as file:
        text = file.read()

    pattern = r'(FEATURE|INCREMENT) (\w+) .*? (\d{1,2}-\w{3}-\d{4}) (\d+)'
    matches = re.findall(pattern, text)

    for match in matches:
        remaining_days = days_until_target(match[2])
        results.append({
            "name": match[1],
            "expiry_date": match[2],
            "total": match[3],
            "remaining_days": remaining_days
        })

    return results

# ... [其他代码部分]

def generate_main_page(files):
    """Generate the main HTML page with links to the individual file reports."""
    html = """
    <html>
    <head>
        <title>Main Report</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            ul { list-style-type: none; }
            li { margin: 20px 0; }
            a { text-decoration: none; color: #007BFF; }
            a:hover { text-decoration: underline; }
        </style>
        <script>
            function runScript() {
                // Use Python to run the Perl script
                var command = "perl path_to_your_script.pl";  // Update the path to your Perl script
                var result = os.system(command);  // Use the os.system method to run the Perl script
                alert("Perl script executed!");  // Notify the user that the script has been executed
            }
        </script>
    </head>
    <body>
        <h1>Files Report</h1>
        <ul>
    """
    
    for file in files:
        file_name = os.path.basename(file)
        html += f'<li><a href="{file_name}.html">{file_name}</a></li>'
    
    # Add a link to execute the Perl script
    html += """
        </ul>
    <a href="#" onclick="runScript()">Run Perl Script</a>
    </body>
    </html>
    """
    return html

# ... [其他代码部分]


def generate_detail_page(file_path, results):
    """Generate detailed HTML report for a specific file."""
    file_basename = os.path.basename(file_path)
    html = f"""
    <html>
    <head>
        <title>Detail Report for {file_basename}</title>
        <style>
            body {{{{ font-family: Arial, sans-serif; margin: 40px; }}}}
            table {{{{ border-collapse: collapse; width: 100%; }}}}
            th, td {{{{ border: 1px solid #dddddd; text-align: left; padding: 8px; }}}}
            tr:nth-child(even) {{{{ background-color: #f2f2f2; }}}}
            tr:hover {{{{ background-color: #ddd; }}}}
            button {{{{ padding: 5px 10px; margin: 0 5px; background-color: green; color: white; border: none; cursor: pointer; }}}}
            button:hover {{{{ background-color: green; }}}}
            .filterInput {{{{ padding: 5px; width: 60%; }}}}
        </style>
        <script>
            var sortOrder = {{{{}}}};

            function filterTable() {{{{
                var input, filter, table, tr, td, i;
                input = document.querySelector(".filterInput");
                filter = input.value.toUpperCase();
                table = document.querySelector("table");
                tr = table.getElementsByTagName("tr");
                for (i = 1; i < tr.length; i++) {{{{
                    td = tr[i].getElementsByTagName("td")[0];
                    if (td) {{{{
                        if (td.innerHTML.toUpperCase().indexOf(filter) > -1) {{{{
                            tr[i].style.display = "";
                        }}}} else {{{{
                            tr[i].style.display = "none";
                        }}}}
                    }}}} 
                }}}}
            }}}}

            function sortTable(n) {{{{
                var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
                table = document.querySelector("table");
                switching = true;
                dir = "asc";
                if (sortOrder[n]) {{{{
                    dir = sortOrder[n];
                }}}}
                while (switching) {{{{
                    switching = false;
                    rows = table.rows;
                    for (i = 1; i < (rows.length - 1); i++) {{{{
                        shouldSwitch = false;
                        x = rows[i].getElementsByTagName("TD")[n];
                        y = rows[i + 1].getElementsByTagName("TD")[n];
                        if (dir == "asc") {{{{
                            if (!isNaN(x.innerHTML) && !isNaN(y.innerHTML)) {
                    if (parseFloat(x.innerHTML) > parseFloat(y.innerHTML)) {
                        shouldSwitch = true;
                        break;
                    }
                } else if (Date.parse(x.innerHTML) && Date.parse(y.innerHTML)) {
                    if (new Date(x.innerHTML) > new Date(y.innerHTML)) {
                        shouldSwitch = true;
                        break;
                    }
                } else if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {{{{
                                shouldSwitch = true;
                                break;
                            }}}}
                        }}}} else if (dir == "desc") {{{{
                            if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {{{{
                                shouldSwitch = true;
                                break;
                            }}}}
                        }}}}
                    }}}}
                    if (shouldSwitch) {{{{
                        rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
                        switching = true;
                        switchcount ++; 
                    }}}} else {{{{
                        if (switchcount == 0 && dir == "asc") {{{{
                            dir = "desc";
                            switching = true;
                        }}}}
                    }}}}
                }}}}
                sortOrder[n] = dir == "asc" ? "desc" : "asc";
            }}}}

            function showFiltered() {{{{
                var rows = document.querySelectorAll("tbody tr");
                rows.forEach(function(row) {{{{
                    var daysCell = row.lastElementChild;
                    if (parseInt(daysCell.textContent) >= 10) {{{{
                        row.style.display = 'none';
                    }}}} else {{{{
                        row.style.display = '';
                    }}}}
                }}}});
            }}}}

            function showAll() {{{{
                var rows = document.querySelectorAll("tbody tr");
                rows.forEach(function(row) {{{{
                    row.style.display = '';
                }}}});
            }}}}
        </script>
    </head>
    <body>
        <h1>Detail Report for {file_basename}</h1>
        <input type="text" class="filterInput" onkeyup="filterTable()" placeholder="Filter by Name...">
        <button onclick="filterTable()">Search</button>
        <button onclick="showFiltered()">Show Entries with Less Than 10 Days</button>
        <button onclick="showAll()">Show All Entries</button>
        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Expiry Date
                        <button onclick="sortTable(1)">Sort</button></th>
                    <th>Total
                        <button onclick="sortTable(2)">Sort</button></th>
                    <th>Remaining Days
                        <button onclick="sortTable(3)">Sort</button></th>
                </tr>
            </thead>
            <tbody>
    """
    
    for item in results:
        html += f"""
            <tr>
                <td>{item["name"]}</td>
                <td>{item["expiry_date"]}</td>
                <td>{item["total"]}</td>
                <td>{item["remaining_days"]}</td>
            </tr>
        """

    html += """
            </tbody>
        </table>
    </body>
    </html>
    """
    return html




# List of files you want to process
files_to_process = [
    r'C:\Users\clancywang\Desktop\flies\license\nowInstall\Cadence_License_8_2_2023.txt',
    r'C:\Users\clancywang\Desktop\flies\license\nowInstall\Synopsys_License_8_2_2023.txt',
    r'C:\Users\clancywang\Desktop\flies\license\nowInstall\Empyrean_License_7_27_2023.txt'
]

log_folder = r'C:\Users\clancywang\Desktop\flies\license\nowInstall'

main_html_content = generate_main_page(files_to_process)

with open(os.path.join(log_folder, 'index.html'), 'w') as main_html_file:
    main_html_file.write(main_html_content)

for file_path in files_to_process:
    results = process_file(file_path)
    detail_html_content = generate_detail_page(file_path, results)
    
    file_name = os.path.basename(file_path)
    with open(os.path.join(log_folder, f'{file_name}.html'), 'w') as detail_html_file:
        detail_html_file.write(detail_html_content)

os.system('firefox ' + os.path.join(log_folder, 'index.html'))

input("Press Enter to close and delete the generated HTML files...")

os.remove(os.path.join(log_folder, 'index.html'))
for file_path in files_to_process:
    file_name = os.path.basename(file_path)
    os.remove(os.path.join(log_folder, f'{file_name}.html'))


import http.server
import socketserver
import subprocess
import os


class MyHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/run-perl-script':
            self.run_perl_script()
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b"Perl script executed!")
        else:
            super().do_GET()

    def run_perl_script(self):
        
        script_path = "/path/to/your/script.pl"
        subprocess.run(['perl', script_path])


PORT = 8080
Handler = MyHttpRequestHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"serving at port {PORT}")
    httpd.serve_forever()

