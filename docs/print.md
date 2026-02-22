
## setup

model: HP OfficeJet Pro x476dw

initial setup:

```
hp-setup <ip of hp printer>
```

loookup current print queues:

```
lpstat -p -d
```
## print cmds

print all pdfs in current directory:

```
find . -maxdepth 1 -type f -iname '*.pdf' -print0 | xargs -0 -r lp -d 35-npv --
```

print in alphatbetical order:

```
find . -maxdepth 1 -type f -iname '*.pdf' -print0 \
  | sort -z -f \
  | xargs -0 -r lp -d 35-npv --

```

### print files in subdirectories

grab all relevant pdf files, put into order:

```
find . -type f -iname '*.pdf' -print0   | \
  sort -z                                | \
  xargs -0 printf '%s\n'
```

redirect to print: 

```
find . -type f -iname '*.pdf' -print0 |
  sort -z |
  xargs -0 -n1 lp -d 35-npv
```