/* fs_kcr.p
 * MODULE
        Название Программного Модуля
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
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/


define shared stream m-out.
def var crlf as char.

def shared temp-table t_kci
             field nn as int 
             field kc10 as decimal format 'z,zzz,zzz,zz9-'
             field kc20 as decimal format 'z,zzz,zzz,zz9-'
             field kc30 as decimal format 'z,zzz,zzz,zz9-'
             field kc40 as decimal format 'z,zzz,zzz,zz9-'
             field kc50 as decimal format 'z,zzz,zzz,zz9-'
             field kc60 as decimal format 'z,zzz,zzz,zz9-'
             field kc70 as decimal format 'z,zzz,zzz,zz9-'
             field kc80 as decimal format 'z,zzz,zzz,zz9-'
             field kc90 as decimal format 'z,zzz,zzz,zz9-'
             field kc95 as decimal format 'z,zzz,zzz,zz9-'
             field kcr10 as decimal format 'z,zzz,zzz,zz9-'
             field kcr20 as decimal format 'z,zzz,zzz,zz9-'
             field kcr30 as decimal format 'z,zzz,zzz,zz9-'
             field kcr40 as decimal format 'z,zzz,zzz,zz9-'
             field kcr50 as decimal format 'z,zzz,zzz,zz9-'
             field kcr60 as decimal format 'z,zzz,zzz,zz9-'
             field kcr70 as decimal format 'z,zzz,zzz,zz9-'
             field kcr80 as decimal format 'z,zzz,zzz,zz9-'
             field kcr90 as decimal format 'z,zzz,zzz,zz9-'
             field kcr95 as decimal format 'z,zzz,zzz,zz9-'.

       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">ОБЪЕМ ВЫДАЧИ ЗАЙМОВ С ФИКСИРОВАННОЙ СТАВКОЙ</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">1-30 дней</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">31-90 дней</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">91-180 дней</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">181-365 дней</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">1-2 года</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Свыше 2 лет</td>"
                  "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы банкам и орг, осуществл. отд. виды банк. опер. </td></tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы, не обеспеченные недвижимостью  </td></tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Факторинг </td>" skip.

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kc10 format '>>>>>>>>>9.99' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Имп/эксорт займы </td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kc20 format '>>>>>>>>>9.99' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Финансовые лизингии</td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kc30 format '>>>>>>>>>9.99' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы на сельхоз цели </td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kc40 format '>>>>>>>>>9.99' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Прочие займы </td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kc50 format '>>>>>>>>>9.99' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы, обеспеченные недвижимостью  </td></tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы на строительство </td>" .

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kc60 format '>>>>>>>>>9.99' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы на покупку недвижимости </td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kc70 format '>>>>>>>>>9.99' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Прочие займы </td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kc80 format '>>>>>>>>>9.99' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы физ лицам на потребительские цели </td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kc90 + t_kci.kc95 format '>>>>>>>>>9.99' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

put stream m-out "</table>" crlf skip.



       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">ОБЪЕМ ВЫДАЧИ ЗАЙМОВ СО СРЕДНЕВЗВЕШЕННОЙ СТАВКОЙ</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">1-30 дней</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">31-90 дней</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">91-180 дней</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">181-365 дней</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">1-2 года</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Свыше 2 лет</td>"
                  "</tr>" crlf skip.


        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы банкам и орг, осуществл. отд. виды банк. опер. </td></tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы, не обеспеченные недвижимостью  </td></tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Факторинг </td>" skip.

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kcr10 / t_kci.kc10 * 100 format '>>9.99%' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Имп/эксорт займы </td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kcr20 / t_kci.kc20 * 100 format '>>9.99%' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Финансовые лизингии</td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kcr30 / t_kci.kc30 * 100 format '>>9.99%' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы на сельхоз цели </td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kcr40 / t_kci.kc40 * 100 format '>>9.99%' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Прочие займы </td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kcr50 / t_kci.kc50 * 100 format '>>9.99%' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы, обеспеченные недвижимостью  </td></tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы на строительство </td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kcr60 / t_kci.kc60 * 100 format '>>9.99%' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы на покупку недвижимости </td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kcr70 / t_kci.kc70 * 100 format '>>9.99%' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Прочие займы </td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " t_kci.kcr80 / t_kci.kc80 * 100 format '>>9.99%' "</td>".
        end.                                                                        
            put stream m-out "</tr>" crlf skip.

        put stream m-out "<tr align=""right"">"
               "<td align=""left""> Займы физ лицам на потребительские цели </td>".

        for each t_kci no-lock.
            put stream m-out "<td align=""right""> " (t_kci.kcr90 + t_kci.kcr95) / (t_kci.kc90 + t_kci.kc95) * 100 format '>>9.99%' "</td>".
        end. 
            put stream m-out "</tr>" crlf skip.



put stream m-out "</table>" crlf skip.
