/* rkcto1c.p
 * MODULE
        Формирование dbf файла для загрузки в 1С
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
        BANK 
 * BASES
     BANK 
 * AUTHOR
        30/11/07 marinav 
 * CHANGES
*/


{global.i}

def new shared temp-table t-jl
    field type as integer
    field deb1 as char 
    field deb2 as char 
    field deb3 as char 
    field cre1 as char 
    field cre2 as char 
    field cre3 as char 
    field amount as deci
    field des as char
    field data as date
    index main type .

def var outf as char.
def var crlf as char.
def var vfile1 as char.
def var vfile2 as char.
crlf = chr(13) + chr(10).
def new shared var v-dat as date .
def new shared var v-summ as deci init 0.

find last cls no-lock no-error.
v-dat = cls.whn.

update v-dat label " Укажите дату" format "99/99/9999"
                  skip with side-label row 5 centered frame dat .

message 'Формирование отчета за ' v-dat.


find first cmp.

FOR EACH jl  where jl.jdt = v-dat NO-LOCK :


  /*погашение кредита МКО*/

      if jl.lev = 1 and jl.sub = 'arp' and jl.acc = '000904401' and jl.dc = 'C'  then do:

               find last ofchis where ofchis.ofc = jl.who and ofchis.regdt le jl.jdt no-lock no-error.
               find last ppoint where ppoint.depart = ofchis.depart no-lock no-error.

                  find first t-jl where t-jl.type = 5 and t-jl.deb1 = ppoint.tel2 and t-jl.cre1 = '00000055' exclusive-lock no-error.
                  if not avail t-jl then do:
                     create t-jl.
                     assign t-jl.type = 5
                            t-jl.deb1 = ppoint.tel2
                            t-jl.deb2 = '00000030'
                            t-jl.deb3 = ''
                            t-jl.cre1 = '00000055'
                            t-jl.cre2 = 'Договор'
                            t-jl.cre3 = ''
                            t-jl.amount = 0
                            t-jl.des = 'Поступление на авансовый счет МКО'
                            t-jl.data = v-dat .
                  end.
                  t-jl.amount = t-jl.amount + jl.cam. 
      end.

  /*погашение кредита Метрокомбанка*/

      if jl.lev = 1 and jl.sub = 'arp' and jl.acc = '000904100' and jl.dc = 'C'  then do:

               find last ofchis where ofchis.ofc = jl.who and ofchis.regdt le jl.jdt no-lock no-error.
               find last ppoint where ppoint.depart = ofchis.depart no-lock no-error.

                  find first t-jl where t-jl.type = 5 and t-jl.deb1 = ppoint.tel2 and t-jl.cre1 = '00000104' exclusive-lock no-error.
                  if not avail t-jl then do:
                     create t-jl.
                     assign t-jl.type = 5
                            t-jl.deb1 = ppoint.tel2
                            t-jl.deb2 = '00000030'
                            t-jl.deb3 = ''
                            t-jl.cre1 = '00000104'
                            t-jl.cre2 = 'Договор'
                            t-jl.cre3 = ''
                            t-jl.amount = 0
                            t-jl.des = 'Поступление на авансовый счет Метрокомбонка'
                            t-jl.data = v-dat .
                  end.
                  t-jl.amount = t-jl.amount + jl.cam. 
      end.


/*  комиссиия с НДС только по счету 460721 */
/*    if jl.gl = 460721 and jl.dc = 'C' then do:

       find last ofchis where ofchis.ofc = jl.who and ofchis.regdt le jl.jdt no-lock no-error.
       find last ppoint where ppoint.depart = ofchis.depart no-lock no-error.

          find t-jl where t-jl.type = 5 and t-jl.deb1 = ppoint.tel2 exclusive-lock no-error.
          if not avail t-jl then do:
             create t-jl.
             assign t-jl.type = 5
                    t-jl.deb1 = ppoint.tel2
                    t-jl.deb2 = '00000030'
                    t-jl.deb3 = ''
                    t-jl.cre1 = '00000058'
                    t-jl.cre2 = 'Договор'
                    t-jl.cre3 = ''
                    t-jl.amount = 0
                    t-jl.des = 'Поступление на авансовый счет'
                    t-jl.data = v-dat .
          end.
          t-jl.amount = t-jl.amount + txb.jl.cam. 

          find t-jl where t-jl.type = 19 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
          if not avail t-jl then do:
             create t-jl.
             assign t-jl.type = 19
                    t-jl.deb1 = '00000058'
                    t-jl.deb2 = 'Договор'
                    t-jl.deb3 = 'КомиссииПрочие'
                    t-jl.cre1 = txb.cmp.addr[3]
                    t-jl.cre2 = '00000001'
                    t-jl.cre3 = '00000001'
                    t-jl.amount = 0
                    t-jl.des = 'Начисление КомиссииПрочие без НДС'
                    t-jl.data = v-dat .
          end.
          t-jl.amount = t-jl.amount + (txb.jl.cam / 1.14). 

          find t-jl where t-jl.type = 20 and t-jl.cre1 = txb.cmp.addr[3] exclusive-lock no-error.
          if not avail t-jl then do:
             create t-jl.
             assign t-jl.type = 20
                    t-jl.deb1 = '00000058'
                    t-jl.deb2 = 'Договор'
                    t-jl.deb3 = 'КомиссииПрочие'
                    t-jl.cre1 = txb.cmp.addr[3]
                    t-jl.cre2 = '00000001'
                    t-jl.cre3 = '00000001'
                    t-jl.amount = 0
                    t-jl.des = 'Погашение КомиссииПрочие '
                    t-jl.data = v-dat .
          end.
          t-jl.amount = t-jl.amount + txb.jl.cam . 

          find t-jl where t-jl.type = 21 exclusive-lock no-error.
          if not avail t-jl then do:
             create t-jl.
             assign t-jl.type = 21
                    t-jl.deb1 = '00000058'
                    t-jl.deb2 = 'Договор'
                    t-jl.deb3 = 'КомиссииПрочие'
                    t-jl.cre1 = '00000013'
                    t-jl.cre2 = ''
                    t-jl.cre3 = ''
                    t-jl.amount = 0
                    t-jl.des = 'КомиссииПрочие НДС'
                    t-jl.data = v-dat .
          end.
          t-jl.amount = t-jl.amount + (txb.jl.cam - (txb.jl.cam / 1.14)). 

    end. 
*/

end.       




def stream s1.
OUTPUT STREAM s1 TO jl_lon.txt.

   for each t-jl no-lock :

        put stream s1 unformatted trim(string(t-jl.type,">9")) + "|" +
              trim(t-jl.deb1) + "|" + 
              trim(t-jl.deb2) + "|" + 
              trim(t-jl.deb3) + "|" + 
              trim(t-jl.cre1) + "|" + 
              trim(t-jl.cre2) + "|" + 
              trim(t-jl.cre3) + "|" + 
              trim(string(t-jl.amount,">>>>>>>>>>>>>>>9.99")) + "|" +
              trim(t-jl.des) + "|" +
              string(year(t-jl.data),"9999") + string(month(t-jl.data),"99") + string(day(t-jl.data),"99") 
              crlf.

   end.

OUTPUT STREAM s1 CLOSE.


   outf = "RK" + substr(string(year(v-dat),"9999"),3,2) + string(month(v-dat),"99") + string(day(v-dat),"99").
 
           unix silent value('un-dos jl_lon.txt ' + outf ).

           unix SILENT value ('1c_dbf.pl ' + outf).

           unix silent value('cp txb.dbf ' + outf + '.dbf' ).

           unix SILENT value('rm -f jl_lon.txt').


find first cmp.
define stream rep.
output stream rep to rkc.htm.

put stream rep unformatted "<html><head><title>РКЦ-1</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

put stream rep unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)'
                 "</h3></td></tr><br><br>" skip.

put stream rep unformatted "<tr align=""center""><td><h3>Погашение кредитов за " string(v-dat) "<BR>".
put stream rep unformatted "</h3></td></tr><br><br>" skip.

put stream rep unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"                  
                  "<td>Тип</td>"
                  "<td>Субконто <br> Дебета 1</td>"
                  "<td>Субконто <br> Дебета 2</td>"
                  "<td>Субконто <br> Дебета 3</td>"
                  "<td>Субконто <br> Кредита 1</td>"
                  "<td>Субконто <br> Кредита 2</td>"
                  "<td>Субконто <br> Кредита 3</td>"
                  "<td>Сумма</td>"
                  "<td>Содержание</td>"
                  "<td>Дата</td>" skip.

for each t-jl.
     put stream rep unformatted "<tr align=""right"">"
               "<td align=""center"">" t-jl.type "</td>" skip
               "<td align=""left"">&nbsp;" t-jl.deb1 "</td>" skip
               "<td align=""left"">&nbsp;" t-jl.deb2 "</td>" skip
               "<td align=""left"">&nbsp;" t-jl.deb3 "</td>" skip
               "<td align=""left"">&nbsp;" t-jl.cre1 "</td>" skip
               "<td align=""left"">&nbsp;" t-jl.cre2 "</td>" skip
               "<td align=""left"">&nbsp;" t-jl.cre3 "</td>" skip
               "<td>" replace(trim(string(t-jl.amount, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""left"">" t-jl.des "</td>" skip
               "<td>" t-jl.data "</td>" skip
               "</tr>".      

end.
put stream rep "</table></body></html>" skip.
output stream rep close.

vfile1 = outf + ".html".
vfile2 = outf + ".dbf".

unix silent un-win rkc.htm value(vfile1).

run mail('id00139@metrobank.kz;id00149@metrobank.kz', "RKC NK <abpk@metrobank.kz>",
             "Файл для загрузки в 1С РКЦ-1 за " + string(v-dat) , "" , "1", "", vfile1 + ";" + vfile2).
 

run mail('id00005@metrobank.kz', "RKC NK <abpk@metrobank.kz>",
             "Файл для загрузки в 1С РКЦ-1 за " + string(v-dat) , "" , "1", "", vfile1 + ";" + vfile2).

unix silent value ("rm txb.dbf").
unix silent value ("rm " + vfile1).
unix silent value ("rm " + vfile2).
unix silent value ("rm " + outf).

hide message no-pause.





