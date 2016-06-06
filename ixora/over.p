/* over.p
 * MODULE
        Межбанковские кредиты и депозиты         
 * DESCRIPTION
        Отчет о минимальных резервных требований.
 RUN
 * CALLER
        стандартные для процессов
 * SCRIPT
        стандартные для процессов
 * INHERIT
        стандартные для процессов
 * MENU
        11-10
 * AUTHOR
        26/08/05 ten
 * CHANGES
*/

def temp-table  tmpr
  field tmpr_rdt     as    date 
  field tmpr_amt     as    deci. 

def var v-text   as char. 
def var v-indir  as char. 
def var v-infile as char. 
def var v-ekshst as char. 
def var s        as char. 
def var v-str    as char. 

def var is_final as logical.

def stream str0.
def stream str1.
def stream str2.
def stream str4.

def input parameter v-input as date.
def output parameter v-out1 as dec.
def var v-dtb as date.
def var v-dte as date.



v-dtb = v-input.
v-dte = v-dtb.

find sysc where sysc.sysc = "lbHST" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-text = " ERROR !!! There isn't record LBHST in sysc file !! ".
   message v-text .
end.                          
v-ekshst = sysc.chval .
/* ntmain */


find sysc where sysc.sysc = "lbeks" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record LBEKS in sysc file !! ".
  message v-text .
end.

v-text = sysc.chval.


if substr(v-text, length(v-text), 1) <> "\/" then v-text = v-text + "/".

v-text = replace ( v-text , "/", "\\" ). 
v-text = replace ( v-text , "\\", "\\\\" ). 


v-indir = v-text + "TRANSIT". 

input stream str0 through value("rsh " + v-ekshst + " dir /b /ad " + v-indir) no-echo.
    repeat:
        import stream str0 unformatted s.
        /* Проверяем Дата это или нет */
        if num-entries (s,"-") <> 3 then next.
        
/*        displ string(date(entry(3, s ,"-") + "/" + entry(2, s  ,"-") + "/"  + entry(1, s, "-"))) v-dtb v-dte. */

        if date(entry(3, s ,"-") + "/" + entry(2, s  ,"-") + "/"  + entry(1, s, "-")) < v-dtb or date(entry(3, s ,"-") + "/" + entry(2, s  ,"-") + "/"  + entry(1, s, "-"))  > v-dte then next.

        v-infile = v-indir + "\\\\" + s.
         input stream str1 through value("rsh  " + v-ekshst + " dir /b /ad " + v-infile) no-echo.
        repeat:
           import stream str1 unformatted s.
           if trim(s) = "940" then do:
                 input stream str2 through value("rsh  " + v-ekshst + " dir /b " + v-infile + "\\\\940\\\\*.exp") no-echo.
                 repeat:
                      
                      import stream str2 unformatted s.
                      s = trim(s).
                      
                      if substr (s, (length(s) - 3), 4) <> ".EXP" then next.

                      unix silent value ("rcp " + v-ekshst + ":" + v-infile + "\\\\940\\\\" + trim(s) + " repf940p.txt").

                      is_final =  false.

                      input stream str4 from "repf940p.txt".
                      repeat:
                        import stream str4 unformatted v-str.
                        v-str = trim(v-str).
                        v-str = replace ( v-str , ",", "." ). 

                        if v-str begins ":23:FINAL" then 
                        is_final =  true.

                        if v-str begins ":62F" and is_final then do:
                           create tmpr.
                               tmpr.tmpr_rdt = date (substr(v-str,11,2) + substr(v-str,9,2) + substr(v-str,7,2)).
                               tmpr.tmpr_amt = decimal (substr(v-str,16)). 
                        end.
                      end.
                      input stream str4 close.

                 end.
                 input stream str2 close.
           end.
        end.
        input stream str1 close.
    end.
input stream str0 close.



for each tmpr break by tmpr_rdt.
v-out1 = tmpr.tmpr_amt.
    end.

