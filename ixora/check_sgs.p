/* check_sgs.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Проверка ЭЦП
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-1
 * AUTHOR
        16/12/2005 tsoy 
 * CHANGES
        tsoy добавил проверку CRL
        07/06/06 Расскоментарил чистку 
*/                                                 

def input  parameter p-docid as int.
def output parameter p-rez   as logi .

def var v-s  as char.
def var v-ms  as char.

def var v-grep as char.

def var v-m as char.
def var v-d as char.
def var v-y as char.



def var v-ok as logi init false.

def buffer a-usr for usr.
def buffer b-usr for usr.

p-rez  = false.

def var v-fmsg  as char.
def var v-fsgs  as char.
def var v-out  as char.

/* убирем за собой */
procedure clear_space. 

   unix silent value ("rm " + v-fmsg) .
   unix silent value ("rm " + v-fsgs) .
   unix silent value ("rm " + v-out) .
end.

run savelog ("sg", string(p-docid) + " Document ").
/* Найдем пользователя */
find ib.doc where ib.doc.id = p-docid no-lock  no-error.

if avail ib.doc  then do:
    find ib.usr where ib.usr.id = ib.doc.id_usr no-lock no-error.
    if avail ib.usr then do:

         /* выгружаем в файлы */
         v-fmsg = "msg" + string(doc.id).
         v-fsgs = "sgs" + string(doc.id).
         v-out  = "out" + string(doc.id).

         output to value(v-fmsg).
         put unformatted doc.msg.

         output close.

         output to value(v-fsgs).
/*          put unformatted "-----BEGIN PKCS7-----" skip. */
            put unformatted doc.sgs. 
/*          put unformatted "-----END PKCS7-----" skip.   */
         output close.

         /* проверяем подпись */
/*       input through value("/usr/local/ssl/bin/openssl smime -verify -inform PEM -in " + v-fsgs + "  -content " + v-fmsg + " -CAfile /pragma/crt/ca.cer  -out " + v-out ) no-echo. */

         input through value("/Certex/verify " + v-fmsg  + " " + v-fsgs + " " + string(p-docid) + " " + string(ib.usr.varatr[9])) no-echo.
         repeat:
            import unformatted v-s.
         end.

/*       if trim(v-s) = 'Verification successful'  then v-ok = true.  else do:   */
         if trim(v-s) = '0'  then v-ok = true.  else do:
           p-rez  = false.
           run clear_space. 
           run savelog ("sg", string(p-docid) + " Verification successful  FALSE").
           return. 
         end.
   end.
end.

run savelog ("sg", string(p-docid) + " Verification successful  OK").


/* Проверим соответсвие подписи данных в <form>  */
/*
if v-ok then do:
         input through value("whomcert " + v-fsgs) no-echo.
         repeat:
            import v-s.
         end.
  
         if trim(v-s) = ib.usr.login then 
             v-ok = true.  
         else do: 
              Поищем связку с другими логинами 
             find first a-usr where a-usr.login = trim(v-s) no-lock no-error.
             find first b-usr where b-usr.login = ib.usr.login no-lock no-error.

             find first shr where shr.who = a-usr.id  and shr.whom = b-usr.id no-lock no-error.
             if not avail shr then do:
                 p-rez = false. 
                 run clear_space. 
                 run savelog ("sg", string(p-docid) + " LOGIN FALSE").
                 return. 
             end.
         end.
end.
run savelog ("sg", string(p-docid) + " LOGIN OK").
*/

/* Проверим CRL list  */
/*
if v-ok then do:

         input through value("/usr/local/ssl/bin/openssl pkcs7 -in " + v-fsgs + "  -print_certs | /usr/local/ssl/bin/openssl x509 -serial -noout " ) no-echo.
         repeat:
            import unformatted v-s.
         end.

         v-s = substr(trim(v-s), 8).
         
         v-grep = "".

         input through value("grep " + v-s + " /pragma/crt/txb.crl" ) no-echo.
         repeat:
               import unformatted v-grep no-error.
         end.
         
         if v-grep <> "" then do:
                 p-rez = false. 
                 run clear_space. 
                 run savelog ("sg", string(p-docid) + " CRL FALSE").
                 return. 
         end.
end.
run savelog ("sg", string(p-docid) + " CRL OK").
*/
/*
/* Проверим DATE  */
if v-ok then do:
     input through value("/usr/local/ssl/bin/openssl pkcs7 -in " + v-fsgs + "  -print_certs | /usr/local/ssl/bin/openssl x509 -enddate -noout " ) no-echo.
     repeat:
        import unformatted v-s.
     end.

     v-s  = substr(trim(v-s), 10).

     v-ms =  substr(trim(v-s), 1,3) .

  /* notAfter=Dec 29 03:36:53 2007 GMT */

     case v-ms:
         when  "Jan" then v-m = "01".
         when  "Feb" then v-m = "02".
         when  "Mar" then v-m = "03".
         when  "Apr" then v-m = "04".
         when  "May" then v-m = "05".
         when  "Jun" then v-m = "06".
         when  "Jul" then v-m = "07".
         when  "Aug" then v-m = "08".
         when  "Sep" then v-m = "09".
         when  "Oct" then v-m = "10".
         when  "Nov" then v-m = "11".
         when  "Dec" then v-m = "12".
     otherwise v-m = "12".
     end case.

     message v-d + "/" + v-m +  "/" + v-y   view-as alert-box.
  
end.
run savelog ("sg", string(p-docid) + " DATE OK").
*/

run savelog ("sg", string(p-docid) + " DOCUMENT OK").

run clear_space.
p-rez = v-ok.

return.

