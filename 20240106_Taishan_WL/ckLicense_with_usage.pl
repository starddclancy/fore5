import http.server
import socketserver
import subprocess
import webbrowser
import os
import re
from datetime import datetime, timedelta


def days_until_target(date_str):
    """Calculate days from today to the target date."""
    target_date = datetime.strptime(date_str, "%d-%b-%Y")
    return (target_date - datetime.today()).days


def process_file(file_path):
    with open(file_path, 'r') as file:
        text = file.read()

    pattern = r'(FEATURE|INCREMENT) (\w+) .*? (\d{1,2}-\w{3}-\d{4}) (\d+)'
    matches = re.findall(pattern, text)

    results = []
    for match in matches:
        name, expiry_date, total = match[1], match[2], match[3]
        remaining_days = days_until_target(expiry_date)
        results.append({
            "name": name,
            "expiry_date": expiry_date,
            "total": total,
            "remaining_days": remaining_days
        })

    return results


def generate_detail_page(file_path, results):
    """Generate detailed HTML report for a specific file."""
    file_basename = os.path.basename(file_path)
    html_content = f"""
    <html>
    <head>
        <title>Detail Report for {file_basename}</title>
    </head>
    <body>
        <h1>Detail Report for {file_basename}</h1>
        <a href="/">Back to main page</a>
        <table border="1">
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Expiry Date</th>
                    <th>Total</th>
                    <th>Remaining Days</th>
                </tr>
            </thead>
            <tbody>
    """
    
    for item in results:
        html_content += f"""
            <tr>
                <td>{item["name"]}</td>
                <td>{item["expiry_date"]}</td>
                <td>{item["total"]}</td>
                <td>{item["remaining_days"]}</td>
            </tr>
        """
    html_content += """
            </tbody>
        </table>
    </body>
    </html>
    """
    return html_content


class MyHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()

            # Main page's HTML content
            html_content = """
            <html>
                <body>
                    <h1>License Check Dashboard</h1>
                    <ul>
                        <li><a href="C:\Users\clancywang\Desktop\flies\license\nowInstall\Cadence_License_8_2_2023.txt">File 1</a></li>
                        <li><a href="C:\Users\clancywang\Desktop\flies\license\nowInstall\Synopsys_License_8_2_2023.txt">File 2</a></li>
                        <li><a href="C:\Users\clancywang\Desktop\flies\license\nowInstall\Empyrean_License_7_27_2023.txt">File 3</a></li>
                    </ul>
                    <br>
                    <!-- Hyperlink to trigger the Perl script -->
                    <a href="C:\Users\clancywang\Desktop\Code\新建文件夹\test.pl">Run the .pl script</a>
                </body>
            </html>
            """
            self.wfile.write(bytes(html_content, "utf-8"))
            
        elif self.path in ["/path/to/first/file.txt", "/path/to/second/file.txt", "/path/to/third/file.txt"]:
            # This is the logic to generate the HTML detail page
            file_path = self.path[1:]  # Remove the leading "/"
            results = process_file(file_path)
            detail_html_content = generate_detail_page(file_path, results)
            self.wfile.write(bytes(detail_html_content, "utf-8"))

        elif self.path == '/run-script':
            # Run the .pl script
            script_path = "/path/to/your/script.pl"
            subprocess.run(['perl', C:\Users\clancywang\Desktop\Code\新建文件夹\test.pl])
            
            # Redirect back to the main page
            self.send_response(302)
            self.send_header('Location', '/')
            self.end_headers()


# Use Python's built-in HTTP server functionality
with socketserver.TCPServer(("", 8080), MyHttpRequestHandler) as httpd:
    webbrowser.open('http://localhost:8080/')  # Automatically open in the default browser
    httpd.serve_forever()
