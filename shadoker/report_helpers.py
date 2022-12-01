from enum import Enum
from typing import Sequence


class OutputFormat(Enum):
    TEXT = 1
    HTML = 2
    CSV = 3
    METRICS = 4

    @staticmethod
    def parse(s : str) -> 'OutputFormat':
        s = str(s).upper()
        if (s == 'HTML' or s == '2'):
            return OutputFormat.HTML
        if (s == 'CSV' or s == '3'):
            return OutputFormat.CSV
        if (s == 'METRICS' or s == '4'):
            return OutputFormat.METRICS
        return OutputFormat.TEXT


def beginHtmlReportTable(r: Sequence[str], table_id: str, *columns) -> Sequence[str]:
    if (r == None):
        r = list()
    r.append('<html>')
    r.append(' <head>')
    r.append('  <style>')
    r.append(f'#{table_id} {{font-family: "Trebuchet MS", Arial, Helvetica, sans-serif; border-collapse: collapse;}}')
    r.append(f'#{table_id} td, #{table_id} th {{border: 1px solid #ddd; padding: 8px;}}')
    r.append(f'#{table_id} tr:nth-child(even) {{background-color: #f2f2f2;}}')
    r.append(f'#{table_id} tr:hover {{background-color: #ddd;}}')
    r.append(f'#{table_id} tr.error {{font-weight: bold; color: darkred;}}')
    r.append(f'#{table_id} th {{padding-top: 12px; padding-bottom: 12px; text-align: left; background-color: #4CAF50; color: white;}}')
    r.append('  </style>')
    r.append(' </head>')
    r.append(' <body>')
    r.append(f' <table id="{table_id}">')
    columns_headers = ''.join(map(lambda s: f'<th>{s}</th>', columns))
    r.append(f'  <tr>{columns_headers}</tr>')
    return r


def addHtmlReportTableData(r: Sequence[str], *values) -> Sequence[str]:
    columns_values = ''.join(map(lambda s: f'<td>{s}</td>', values))
    r.append(f'  <tr>{columns_values}</tr>')
    return r


def addHtmlReportTableDataError(r: Sequence[str], *values) -> Sequence[str]:
    columns_values = ''.join(map(lambda s: f'<td>{s}</td>', values))
    r.append(f'  <tr class="error">{columns_values}</tr>')
    return r


def endHtmlReportTable(r: Sequence[str]) -> str:
    r.append(' </table>')
    r.append(' </body>')
    r.append('</html>')
    return r


def beginCsvReportTable(r: Sequence[str], separator: str, *columns) -> Sequence[str]:
    if (r == None):
        r = list()
    columns_headers = separator.join(map(str, columns))
    r.append(f'{separator}{columns_headers}{separator}')
    return r


def addCsvReportTableData(r: Sequence[str], separator: str, *values) -> Sequence[str]:
    columns_values = separator.join(map(str, values))
    r.append(f'{separator}{columns_values}{separator}')
    return r


def endCsvReportTable(r: Sequence[str], separator: str) -> str:
    return r