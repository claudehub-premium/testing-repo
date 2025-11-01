# Wordlists Directory

This directory contains wordlists for weak password detection in configuration files.

## Available Wordlists

- **common.txt** - Minimal set of 6 most common weak passwords
- **top100.txt** - Top 100 most common passwords
- **top1000.txt** - Top 1000 most common passwords (abbreviated)
- **rockyou.txt** - (Optional) Add your own RockYou wordlist here

## Usage

Use the `--wordlist` or `-w` flag when running the scanner:

### Interactive Selection
```bash
crystal run vuln_scanner.cr --wordlist 192.168.1.100
```

This will present a menu to select from available wordlists.

### Direct Path
```bash
crystal run vuln_scanner.cr -w wordlists/top1000.txt 192.168.1.100
```

### Custom Wordlist
```bash
crystal run vuln_scanner.cr -w /path/to/custom/wordlist.txt 192.168.1.100
```

## Wordlist Format

Wordlists should be plain text files with one password per line:
```
password
123456
admin
root
```

Lines starting with `#` are treated as comments and ignored.
