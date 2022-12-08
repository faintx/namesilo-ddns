## change namesilo DNS A/AAAA records, inspired of [namesilo_ddns](https://github.com/pztop/namesilo_ddns)

### how to use
1. install libxml2-utils  
`sudo apt install libxml2-utils`
2. `crontab -e`  
3. hourly  
   - `0 * * * * $HOME/namesilo_ddns.sh > /dev/null 2>&1`  
   - or `@hourly $HOME/namesilo_ddns.sh > /dev/null 2>&1`
4. every 2 hours  
 `* */2 * * * $HOME/namesilo_ddns.sh > /dev/null 2>&1`

### Prerequisites:

* Generate API key in the “api manager” at Namesilo

* Make sure your system have command `dig` and `xmllint`. If not, install them:

on CentOS:

```sudo yum install bind-utils libxml2```
    
on Ubuntu/Debian:

```sudo apt-get install dnsutils libxml2-utils```

### How to use:
* Download and save the Bash script.
* Modify the script, set “DOMAIN”, “HOST”, and “APIKEY” at the beginning of the script.
* Set file permission to make it executable.
* Create cronjob (optional)
