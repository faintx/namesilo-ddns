## change namesilo DNS AAAA records, inspired of [namesilo_ddns](https://github.com/pztop/namesilo_ddns)

### how to use
1. install libxml2-utils  
`sudo apt install libxml2-utils`
2. `crontab -e`  
3. hourly  
   - `0 * * * * $HOME/namesilo_ddns.sh > /dev/null 2>&1`  
   - or `@hourly $HOME/namesilo_ddns.sh > /dev/null 2>&1`
4. every 2 hours  
 `* */2 * * * $HOME/namesilo_ddns.sh > /dev/null 2>&1`
