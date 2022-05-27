## change namesilo DNS AAAA records, inspire of [namesilo_ddns](https://github.com/pztop/namesilo_ddns)

### how to use

1. `crontab -e`  
2. hourly  
- `0 * * * * $HOME/namesilo_ddns.sh > /dev/null 2>&1`  
 or `@hourly $HOME/namesilo_ddns.sh > /dev/null 2>&1`
- every 2 hours  
 `* */2 * * * $HOME/namesilo_ddns.sh > /dev/null 2>&1`
