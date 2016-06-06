/* r-obvalk.p
 * MODULE
        Обменные операции
 * DESCRIPTION
	Отчет кассира по купле-продаже инвалюты
 * RUN
        меню
 * CALLER
        nmenu
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-1-12-3
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       23/01/2006 u00121 отсутствовала обработка счетов 100200 и 100300, т.к. обменные операция стали проводиться по выходным через 100200, по звонку u00079 была добавлена такая обработка
       02.03.12 damir - вывод формы в формате WORD (без возможности редактирования) Т.З. № 1256, добавил menu-prt.
*/

/* r-obvalk.p
   ОБЪЕМ КУПЛЕННОЙ И ПРОДАННОЙ ИНОСТРАННОЙ ВАЛЮТЫ ЗА ДЕНЬ
   (для кассира)
   29.11.2000 */

{keyord.i} /*Переход на новые и старые форматы форм*/

def  var      v-dat as    date.
def  temp-table temp
     field    jh    like  jl.jh
     field    dc    as    char format 'x(1)'
     field    debv  like  joudoc.dramt format "zzzz,zzz,zz9.99"
     field    debt  like  joudoc.dramt format "zzzz,zzz,zz9.99"
     field    credv like  joudoc.dramt format "zzzz,zzz,zz9.99"
     field    credt like  joudoc.dramt format "zzzz,zzz,zz9.99"
     field    crc   like  crc.crc
     field    rate  like  joudoc.srate format 'zz9.99'.

def  stream   m-out.

def stream v-out.
def stream v-out2.

def var v-file  as char init "Rep1.htm".
def var v-file2 as char init "Rep2.htm".
def var v-inputfile as char init "/data/export/report.htm".
def var v-str       as char.

{global.i}
{functions-def.i}

find last cls no-lock no-error.
g-today = if available cls then cls.cls + 1 else today.
v-dat = g-today.
if not g-batch then do:
 update v-dat label ' Укажите дату ' format '99/99/9999' skip
        with side-label row 5 centered frame dat .
end.
else v-dat = g-today.

display '   Ждите...   '  with row 5 frame ww centered .

output stream m-out to rpt.img.

put stream m-out
FirstLine( 1, 1 ) format 'x(80)' skip(1)
'            '
'ОБЪЕМ КУПЛЕННОЙ И ПРОДАННОЙ ИНОСТРАННОЙ ВАЛЮТЫ  '  skip
'                            '
'за ' string(v-dat) skip(1)
FirstLine( 2, 1 ) format 'x(80)' skip.
put stream m-out  fill( '-', 80 ) format 'x(80)'  skip.
put stream m-out
' N ТРАНЗ.'
'                ПОКУПКА'
'                       ПРОДАЖА '
'           КУРС  '
skip.
put stream m-out
'         '
'         валюта    /     тенге  '
'       валюта    /     тенге '
'   '
skip.
put stream m-out  fill( '-', 80 ) format 'x(80)'  skip(1).

output stream v-out  to value(v-file).
output stream v-out2 to value(v-file2).


input from value(v-inputfile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    put stream v-out unformatted v-str.
end.
input close.
put stream v-out unformatted
    "<P align=left>" FirstLine( 1, 1 ) "</P>" skip
    "<P></P>" skip
    "<P align=center>ОБЪЕМ КУПЛЕННОЙ И ПРОДАННОЙ ИНОСТРАННОЙ ВАЛЮТЫ за " string(v-dat) "</P>" skip
    "<P></P>" skip
    "<P align=left>" FirstLine( 2, 1 ) "</P>" skip
    "<TABLE width=""100%"" bordercolor=""white"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR align=center><FONT size=2>" skip
    "<TD>N ТРАНЗ.</TD>" skip
    "<TD colspan=2>ПОКУПКА</TD>" skip
    "<TD colspan=2>ПРОДАЖА</TD>" skip
    "<TD>КУРС</TD>" skip
    "</FONT></TR>" skip
    "<TR align=center><FONT size=2>" skip
    "<TD>" "</TD>" skip
    "<TD>валюта</TD>" skip
    "<TD>тенге</TD>" skip
    "<TD>валюта</TD>" skip
    "<TD>тенге</TD>" skip
    "<TD>" "</TD>" skip
    "</FONT></TR>" skip.


for each jl where jdt = v-dat and (gl = 100100 or gl = 100200 or gl = 100300) /*u00121 23/01/2006 отсутствовала обработка счетов 100200 и 100300*/
and substring(rem[1],1,5) = "Обмен" and crc <> 1 and who = userid('bank') and ((dam <> 0 and ln = 1) or  (cam <> 0  and ln = 4)).
    find joudoc where joudoc.jh = jl.jh and joudoc.who = jl.who no-lock no-error.
    if avail joudoc then do:
        create temp.
        temp.jh = jl.jh.
        if jl.dam <> 0 then do.
            temp.dc    = 'd'.
            temp.debv  = joudoc.dramt.
            temp.debt  = joudoc.cramt.
            temp.crc   = jl.crc.
            temp.rate  = joudoc.brate.
        end.
        else do.
            temp.dc    = 'c'.
            temp.credv = joudoc.cramt.
            temp.credt = joudoc.dramt.
            temp.crc = jl.crc.
            temp.rate = joudoc.srate.
        end.
    end.
end.
for each temp break by temp.crc by temp.dc by temp.rate by temp.credv by temp.debv.
    accum temp.debv  (total by temp.crc by temp.rate).
    accum temp.debt  (total by temp.crc by temp.rate).
    accum temp.credv (total by temp.crc by temp.rate).
    accum temp.credt (total by temp.crc by temp.rate).
    if first-of(temp.crc) then do.
        find crc where crc.crc = temp.crc no-lock no-error.
        if avail crc then do:
            put stream m-out
                '  Валюта: ' crc.des skip
                space(2) fill( '-', 20 ) format 'x(20)'  skip(1).

            put stream v-out unformatted
                "<TR><FONT size=2>" skip
                "<TD>Валюта:</TD>" skip
                "<TD colspan=2>" crc.des "</TD>" skip
                "<TD colspan=2></TD>" skip
                "<TD></TD>" skip
                "</FONT></TR>" skip.
        end.
    end.

    put stream m-out temp.jh ' ' .
    if temp.debv <> 0 then put stream m-out temp.debv temp.debt.
    else put stream m-out space(30).
    if temp.credv <> 0 then put stream m-out temp.credv temp.credt .
    else put stream m-out space(30).
    put stream m-out '   ' temp.rate format '>>9.99' skip.

    put stream v-out unformatted
        "<TR><FONT size=2>" skip
        "<TD>" string(temp.jh) "</TD>" skip
        "<TD>" string(temp.debv,"z,zzz,zzz,zz9.99-") "</TD>" skip
        "<TD>" string(temp.debt,"z,zzz,zzz,zz9.99-") "</TD>" skip
        "<TD>" string(temp.credv,"z,zzz,zzz,zz9.99-") "</TD>" skip
        "<TD>" string(temp.credt,"z,zzz,zzz,zz9.99-") "</TD>" skip
        "<TD>" string(temp.rate,">>9.99") "</TD>" skip
        "</FONT></TR>" skip.

    if last-of(temp.rate) then do.
       put stream m-out '  Всего: '.
       if temp.dc = 'd' then
          put stream m-out
              accum total by temp.rate temp.debv format "zzzz,zzz,zz9.99"
              accum total by temp.rate temp.debt format "zzzz,zzz,zz9.99"
              skip(1).
       else
          put stream m-out space(30)
              accum total by temp.rate temp.credv format "zzzz,zzz,zz9.99"
              accum total by temp.rate temp.credt format "zzzz,zzz,zz9.99"
              skip(1).

        put stream v-out unformatted
            "<TR><FONT size=2>" skip
            "<TD>Всего:</TD>" skip.
        if temp.dc = 'd' then do:
            put stream v-out unformatted
                "<TD>" string(accum total by temp.rate temp.debv,"zzzz,zzz,zz9.99-") "</TD>" skip
                "<TD>" string(accum total by temp.rate temp.debt,"zzzz,zzz,zz9.99-") "</TD>" skip.
        end.
        else do:
            put stream v-out unformatted
                "<TD>" string(accum total by temp.rate temp.credv,"zzzz,zzz,zz9.99-") "</TD>" skip
                "<TD>" string(accum total by temp.rate temp.credt,"zzzz,zzz,zz9.99-") "</TD>" skip.
        end.
        put stream v-out unformatted
            "<TD></TD>" skip
            "<TD></TD>" skip
            "<TD></TD>" skip
            "</FONT></TR>" skip.
    end.
    if last-of(temp.crc) then
        put stream m-out skip(1) '  ИТОГО: '
           accum total by temp.crc temp.debv format "zzzz,zzz,zz9.99"
           accum total by temp.crc temp.debt format "zzzz,zzz,zz9.99"
           accum total by temp.crc temp.credv format "zzzz,zzz,zz9.99"
           accum total by temp.crc temp.credt format "zzzz,zzz,zz9.99"
           skip.

        put stream v-out unformatted
            "<TR><FONT size=2>" skip
            "<TD>ИТОГО:</TD>" skip
            "<TD>" string(accum total by temp.crc temp.debv,"zzzz,zzz,zz9.99-") "</TD>" skip
            "<TD>" string(accum total by temp.crc temp.debt,"zzzz,zzz,zz9.99-") "</TD>" skip
            "<TD>" string(accum total by temp.crc temp.credv,"zzzz,zzz,zz9.99-") "</TD>" skip
            "<TD>" string(accum total by temp.crc temp.credt,"zzzz,zzz,zz9.99-") "</TD>" skip
            "<TD></TD>" skip
            "</FONT></TR>" skip.
end.
put stream v-out unformatted
    "</TABLE>" skip.

put stream m-out  fill( '-', 80 ) format 'x(80)'  skip(1).
output stream m-out close.

output stream v-out close.
input from value(v-file).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*</body>*" then do:
            v-str = replace(v-str,"</body>","").
            next.
        end.
        if v-str matches "*</html>*" then do:
            v-str = replace(v-str,"</html>","").
            next.
        end.
        else v-str = trim(v-str).
        leave.
    end.
    put stream v-out2 unformatted v-str skip.
end.
input close.
output stream v-out2 close.

unix silent cptwin value(v-file2) winword.

pause 0 before-hide .
run menu-prt( 'rpt.img' ).
pause before-hide.

{functions-end.i}
return.
