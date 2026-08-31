The default locale is set in the file [config/application.rb](https://github.com/wiso-forschungslabor/hroot/blob/master/config/application.rb).

The default date format used in emails can be changed in the corresponding language file, for example [config/locales/en.yml](https://github.com/wiso-forschungslabor/hroot/blob/master/config/locales/en.yml):

Change the format of the email key for date and time to suit your needs:

    time:
      formats:
        ...
        email: ! '%H:%M'
    
    date:
      formats:
        ...
        email: "%b %d, %Y"
