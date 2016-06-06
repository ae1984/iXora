/* r-do2.p
 * MODULE
        Расшифровка кор счетов банков
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
       8-2-14-15 
 * AUTHOR
        13.01.2005 marinav
 * CHANGES
        16/03/06 marinav  - добавила отчет в тенге
        28/11/08 marinav  - hisfun заменила на histrxbal
*/
{global.i}
def stream m-err.
def stream m-out.
def var i as int.
def var sych as char.
def var per as char.
def var d_sum like glbal.bal.
def var v-name as char.
def var v-frbno as char.
def var v-stn as char.
def var v-lne as char.
def var v-rate as deci.

def var k as int.

def var m-str as char format "x(60)".
def var m-st as char format "x(122)".
def var m-str1 as char format "x(60)".

def var sumL as deci.
def var sumv as deci.
def var v-rto as date.
def var v-sel as inte.
v-rto = today.

def temp-table kor
field vgl like gl.gl
index kor is unique vgl.


def workfile wf
    field wfun  like fun.fun
    field wname like bankl.bank
    field wgeo as char
    field wgl like fun.gl
    field wrez as char
    field wkod as char
    field wcrc  like crc.crc
    field wsumpr  as decimal format "z,zzz,zzz,zz9.99-"
    field wsumLs  as decimal format "z,zzz,zzz,zz9.99-"
    field wlne like bankl.lne.

def var v-vgl like gl.gl.
output stream m-err to DO2.err.


   run sel ("Выберите тип отчета", "1. В тыс. тенге      |" +
                                   "2. В тенге     ").
       case return-value:
          when "1" then v-sel = 1.
          when "2" then v-sel = 2.
       end.

update v-rto label ' Укажите дату ' format '99/99/9999'
                     skip with side-label row 5 centered frame dat .

find sysc where sysc.sysc = ">BANDR" no-lock no-error.
if available sysc then sych = sysc.chval.
else sych = "1251,1252,1253,1254,1255,1256,1257,".
repeat:
    i = i + 1.
    per = substring(sych,1,index(sych,",") - 1).
    v-vgl = integer(per) no-error.
    if not error-status:error then do:
    find kor where kor.vgl eq v-vgl no-error.
    if not available kor then do:
        create kor.
        kor.vgl = v-vgl.
    end.
    end.
    sych = substring(sych,index(sych,",") + 1,length(sych)).
    if sych = "" or sych = " " then leave.
end.

/******/
for each kor:
    for each fun where string(fun.gl) begins string(kor.vgl) no-lock:
        find last histrxbal where  histrxbal.sub = 'fun' and histrxbal.acc = fun.fun and histrxbal.lev = 1 and histrxbal.dt <= v-rto no-lock no-error. 
        if avail histrxbal and histrxbal.dam ne histrxbal.cam then do:

           find bankl where bankl.bank = fun.bank  no-lock no-error .
           if not available bankl then do:
               put stream m-err " Для " fun.fun " нет описания банка " skip.
               v-name = "". 
               v-frbno = "". 
               v-stn = "".
           end.
           else do:
               v-name = bankl.name.
               v-lne = bankl.lne.
               find codfr where codfr.codfr eq "cntrcode" and codfr.code =
               bankl.frbno no-lock no-error.
               if not available codfr then
               v-frbno = bankl.frbno.
               else v-frbno = codfr.name[1].
               v-stn = string(bankl.stn).
           end.
           find last crchis where crchis.crc = fun.crc and crchis.rdt <= v-rto no-lock no-error.
           if not available crchis then do:
               put stream m-err " Для " fun.fun " нет описания валюты " skip.
           end.    
           else v-rate = crchis.rate[1] / crchis.rate[9].
           
           d_sum = histrxbal.dam - histrxbal.cam.
           if d_sum <> 0 then do:
               find first wf where wf.wfun eq fun.fun and wf.wcrc eq fun.crc 
               no-error.
               if not available wf then do:
                   create wf.
                   wf.wfun  = fun.fun.
                   wf.wname = v-name.
                   wf.wgeo  = substring(v-stn,2,1).
                   wf.wkod  = v-frbno.
                   wf.wcrc  = fun.crc.
                   wf.wgl = fun.gl.
                   wf.wlne = v-lne.
               end.
               if fun.crc eq 1 then wf.wsumLS = wf.wsumLS + d_sum .
               else wf.wsumpr = wf.wsumpr + d_sum * v-rate.
           end.  /*d_sum <> 0*/
        end.
    end.    
end.
for each wf where wf.wgeo eq "1": wf.wrez = "1". end. /*rezidenti*/
for each wf where wf.wgeo ne "1": wf.wrez = "2". end. /*nerezidenti*/

/*for each wf :
put stream m-err wf.wname wf.wfun wf.wsumpr format '>>>,>>>,>>>,>>9.99'  wf.wlne skip.
end.        
*/
output stream m-err close.


output to rep.html.

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

    put unformatted   "<TABLE cellspacing=""0"" cellpadding=""3"" border=""0"">" skip
                         "<tr><td colspan=7 align=""center"" style=""font:bold;font-size:12.0pt;"">РАСШИФРОВКА ОСТАТКОВ БАЛАНСОВЫХ СЧЕТОВ 1052</td></tr>" skip
                         "<tr><td colspan=7 align=""center"" style=""font:bold;font-size:12.0pt;"">1251,1252,1253,1254,1255,1256,1257 В РАЗРЕЗЕ БАНКОВ </td></tr>" skip
                         "<tr><td colspan=7 align=""center"" style=""font:bold;font-size:12.0pt;"">за " v-rto " </td></tr>" skip
                         "<tr><td colspan=7 align=""left"" style=""font:bold;font-size:12.0pt;"">(тыс.тенге)</td></tr>" skip.
    put unformatted "</table>" skip.
    
    put unformatted  "<br><br>".

put  unformatted     
                   "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
                    "<TR align=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
                    "<td rowspan=2>N п/п</td>"
                    "<td rowspan=2>Признак <br>резидентства</td>"
                    "<td  align=rigth rowspan=2>Наименование <br> банка <br> корреспондента</td>"
                    "<td rowspan=2>Местонахождение<br> банка <br> корреспондента </td>"
                    "<td colspan=3>Корр счет </td>"
                    "<td  rowspan=2>Рейтинг</td>"
                  "</tr>" skip.
put  unformatted     
                    "<TR align=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
                    "<td >в национальной <br> валюте</td>"
                    "<td >в иностранной <br> валюте</td>"
                    "<td >итого в<br> тенге </td>"
                  "</tr>" skip.
put  unformatted     
                    "<TR align=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
                    "<td >1</td>"
                    "<td >2</td>"
                    "<td >3</td>"
                    "<td >4 </td>"
                    "<td >5</td>"
                    "<td >6</td>"
                    "<td >7</td>"
                    "<td >8</td>"
                  "</tr>" skip.

k = 0.     
for each wf where wsumLs <> 0 or wsumpr <> 0 : 
    k = k + 1.

   if v-sel = 1 then do:
                put unformatted "<tr align=""right"">"
                   "<td> " k format "zz9" "</td> "
                   "<td align=center> " wrez format "x(3)" "</td> "
                   "<td align=left>" wname format "x(60)" "</td>"
                   "<td align=center >&nbsp; " wkod format "x(5)"  "</td>"
                   "<td> " replace(trim(string(round(wsumLs / 1000, 0), "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(round(wsumpr / 1000, 0), "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td> " replace(trim(string(round((wsumLs + wsumpr) / 1000, 0), "->>>>>>>>>>>9.99")),".",",") "</td>"
                   "<td align=center> " wlne format "x(5)" "</td></tr>" skip.

        sumL = sumL + round(wf.wsumLs / 1000, 0).
        sumv = sumv + round(wf.wsumpr / 1000, 0).
   end.
   else do:
                put unformatted "<tr align=""right"">"
                   "<td> " k format "zz9" "</td> "
                   "<td align=center> " wrez format "x(3)" "</td> "
                   "<td align=left>" wname format "x(38)" "</td>"
                   "<td align=center >&nbsp; " wkod format "x(5)"  "</td>"
                   "<td> " replace(trim(string(wsumLs , "->>>>>>>>>>>9.999")),".",",") "</td>"
                   "<td> " replace(trim(string(wsumpr , "->>>>>>>>>>>9.999")),".",",") "</td>"
                   "<td> " replace(trim(string((wsumLs + wsumpr) , "->>>>>>>>>>>9.999")),".",",") "</td>"
                   "<td align=center> " wlne format "x(5)" "</td></tr>" skip.

        sumL = sumL + wf.wsumLs.
        sumv = sumv + wf.wsumpr.
   end.
  
end.

      put unformatted "<tr align=""right"">"
         "<td> Итого:</td> "
         "<td> </td> "
         "<td></td>"
         "<td></td>"
         "<td>" sumL "</td> "
         "<td>" sumv "</td>"
         "<td>" sumL + sumv "</td>"
/*         "<td> " replace(trim(string(sumL, "->>>>>>>>>>>9.999")),".",",") "</td>"
         "<td> " replace(trim(string(sumv , "->>>>>>>>>>>9.999")),".",",") "</td>"
         "<td> " replace(trim(string(sumL + sumv, "->>>>>>>>>>>9.999")),".",",") "</td>"
*/
         "<td></td></tr>" skip.

    put unformatted   "<TABLE cellspacing=""0"" cellpadding=""3"" border=""0"">" skip
                         "<tr></tr><tr></tr><tr><td colspan=3 align=""rigth"" style=""font:bold;font-size:12.0pt;"">Председатель Правления </td></tr>" skip
                         "<tr></tr><tr><td colspan=3 align=""rigth"" style=""font:bold;font-size:12.0pt;"">Главный бухгалтер </td></tr>" skip.
    put unformatted "</table>" skip.
    
    put unformatted  "<br><br>".

output close.
unix silent cptwin rep.html excel.exe.
