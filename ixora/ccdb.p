/* ccdb.p
* MODULE
    Название модуля - Внутрибанковские операции.
* DESCRIPTION
    Описание - Концентрация клиентской депозитной базы.
* RUN
    Способ вызова программы, описание параметров, примеры вызова
* CALLER
    Список процедур, вызывающих этот файл
* SCRIPT
    Список скриптов, вызывающих этот файл
* INHERIT
    Список вызываемых процедур
* MENU
    Пункт меню
* BASES
    BANK COMM
* AUTHOR
    05/04/2009 evseev
* CHANGES
    15/03/2012 id00810 - название банка из sysc
    25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
    13.07.2011 damir   - эта программа вызывается rep2-1,rep2-2,ccdb0.Добавлены входные параметры и т.д.
    03.10.2011 damir   - объединил отчеты "Концентрация деп.базы ЮЛ и ФЛ". формируются в одном документе, добавил varurfiz.i, поле type в
                         temp-table t-cif,v-urfiz.
    26.10.2011 damir   - устранил мелкие ошибки.
    16.08.2012 damir   - добавил obnulvar.i, поместил все в varurfiz.i, в расчет по ЮЛ (B) и ФЛ (P) добавил счета
                         ГК 2219,2223,2240,2237.
    11.12.2012 damir   - Добавления к изменению 16.08.2012. Поправил в строке 743 (формула) переменную f10_fiz_i2237 на s_fiz_i2237.
    05.02.2012 damir   - Перекомпиляция. Обнаружены небольшие несооветствия. Все исправлено.
    19/09/2013  Luiza  - ТЗ 1945 добавление счета 2213
*/

{global.i}

def input parameter v-option      as char.
def input parameter v-yesterday   as date.
def input parameter v-select      as inte.
def output parameter vfname       as char init "ttt.xls".
def input-output parameter vres   as logi.

def var p-bank as char.
def var i      as inte.

{varurfiz.i "new"}   /*Объявление переменных*/

def var v-sel   as inte no-undo.
def var v-sel2  as inte no-undo.
def var v-file  as char init "ccdb.html"  no-undo.
def var v-file2 as char init "ccdb2.html" no-undo.

def stream rep.

def buffer b-t-cif for t-cif.

def var sum1 as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.
def var sum2 as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.
def var sum3 as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.
def var sum4 as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.
def var sum5 as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.

def var sum1_ur as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.
def var sum2_ur as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.
def var sum3_ur as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.
def var sum4_ur as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.
def var sum5_ur as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.

def var sum1_fiz as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.
def var sum2_fiz as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.
def var sum3_fiz as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.
def var sum4_fiz as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.
def var sum5_fiz as decimal format "zzz,zzz,zzz,zz9.99-" no-undo.

{obnulvar.i} /*обнуление переменных*/

if v-option = "mail" then do:
    v-dt = v-yesterday.
    v-sel2 = v-select.
    v-urfiz = yes.
    find first bank.cmp no-lock no-error.
    if not avail bank.cmp then do:
        message " Не найдена запись cmp " view-as alert-box error.
        return.
    end.
    def var vv-path as char no-undo.
    if bank.cmp.name matches "*МКО*" then vv-path = '/data/'.
    else vv-path = '/data/b'.
    for each comm.txb where comm.txb.consolid = true no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/',vv-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run ccdb1(comm.txb.info).
    end.
    if connected ("txb") then disconnect "txb".
end.
else do:
    update v-dt label "Дата отчета" format "99/99/9999" validate(v-dt <= g-today,"Дата не должна превышать операционную дату!!!") with centered row 5 frame ConsDB.
    run sel2('Выбор отчета',' Концентрация депозитной базы ЮЛ и ФЛ | Крупнейшие держатели текущих счетов ЮЛ | Крупнейшие держатели срочных счетов ЮЛ | Крупнейшие держатели текущих счетов ФЛ | Крупнейшие держатели срочных счетов ФЛ ', output v-sel2).
    case v-sel2:
        when 1 then v-urfiz = yes.
        when 2 then do: v-repnum = 2. v-type = "B". end.
        when 3 then do: v-repnum = 3. v-type = "B". end.
        when 4 then do: v-repnum = 4. v-type = "P". end.
        when 5 then do: v-repnum = 5. v-type = "P". end.
    end case.

    hide all.
    {r-branch.i &proc = "ccdb1(comm.txb.info)"}
    pause 0.
end.

i = 0.
for each t-cif use-index sum no-lock:
   i = i + 1.
   if i <= 10 then do:
      f10_i2203 =  f10_i2203 + t-cif.i2203.
      f10_i2204 =  f10_i2204 + t-cif.i2204.
      f10_i2205 =  f10_i2205 + t-cif.i2205.
      f10_i2206 =  f10_i2206 + t-cif.i2206.
      f10_i2207 =  f10_i2207 + t-cif.i2207.
      f10_i2213 =  f10_i2213 + t-cif.i2213.
      f10_i2215 =  f10_i2215 + t-cif.i2215.
      f10_i2217 =  f10_i2217 + t-cif.i2217.
      f10_i2013 =  f10_i2013 + t-cif.i2013.
      f10_i2123 =  f10_i2123 + t-cif.i2123.
      f10_i2124 =  f10_i2124 + t-cif.i2124.
      f10_i2219 =  f10_i2219 + t-cif.i2219.
      f10_i2223 =  f10_i2223 + t-cif.i2223.
      f10_i2237 =  f10_i2237 + t-cif.i2237.
      f10_i2240 =  f10_i2240 + t-cif.i2240.
   end.
   if i <= 20 then do:
      f20_i2203 = f20_i2203 + t-cif.i2203.
      f20_i2204 = f20_i2204 + t-cif.i2204.
      f20_i2205 = f20_i2205 + t-cif.i2205.
      f20_i2206 = f20_i2206 + t-cif.i2206.
      f20_i2207 = f20_i2207 + t-cif.i2207.
      f20_i2213 = f20_i2213 + t-cif.i2213.
      f20_i2215 = f20_i2215 + t-cif.i2215.
      f20_i2217 = f20_i2217 + t-cif.i2217.
      f20_i2013 = f20_i2013 + t-cif.i2013.
      f20_i2123 = f20_i2123 + t-cif.i2123.
      f20_i2124 = f20_i2124 + t-cif.i2124.
      f20_i2219 = f20_i2219 + t-cif.i2219.
      f20_i2223 = f20_i2223 + t-cif.i2223.
      f20_i2237 = f20_i2237 + t-cif.i2237.
      f20_i2240 = f20_i2240 + t-cif.i2240.
   end.

   if i >= 20 then leave.
end.

/*------------------------------------------------*/
if v-urfiz = yes then do:
    for each t-cif break by t-cif.type:
        if first-of(t-cif.type) then do:
            i = 0.
            for each b-t-cif where b-t-cif.type = t-cif.type use-index sum no-lock:
                i = i + 1.
                if trim(b-t-cif.type) = "B" then do:
                    if i <= 10 then do:
                        f10_ur_i2203 = f10_ur_i2203 + b-t-cif.i2203.
                        f10_ur_i2204 = f10_ur_i2204 + b-t-cif.i2204.
                        f10_ur_i2205 = f10_ur_i2205 + b-t-cif.i2205.
                        f10_ur_i2206 = f10_ur_i2206 + b-t-cif.i2206.
                        f10_ur_i2207 = f10_ur_i2207 + b-t-cif.i2207.
                        f10_ur_i2213 = f10_ur_i2213 + b-t-cif.i2213.
                        f10_ur_i2215 = f10_ur_i2215 + b-t-cif.i2215.
                        f10_ur_i2217 = f10_ur_i2217 + b-t-cif.i2217.
                        f10_ur_i2013 = f10_ur_i2013 + b-t-cif.i2013.
                        f10_ur_i2123 = f10_ur_i2123 + b-t-cif.i2123.
                        f10_ur_i2124 = f10_ur_i2124 + b-t-cif.i2124.
                        f10_ur_i2219 = f10_ur_i2219 + b-t-cif.i2219.
                        f10_ur_i2223 = f10_ur_i2223 + b-t-cif.i2223.
                        f10_ur_i2237 = f10_ur_i2237 + b-t-cif.i2237.
                        f10_ur_i2240 = f10_ur_i2240 + b-t-cif.i2240.
                    end.
                    if i <= 20 then do:
                        f20_ur_i2203 = f20_ur_i2203 + b-t-cif.i2203.
                        f20_ur_i2204 = f20_ur_i2204 + b-t-cif.i2204.
                        f20_ur_i2205 = f20_ur_i2205 + b-t-cif.i2205.
                        f20_ur_i2206 = f20_ur_i2206 + b-t-cif.i2206.
                        f20_ur_i2207 = f20_ur_i2207 + b-t-cif.i2207.
                        f20_ur_i2213 = f20_ur_i2213 + b-t-cif.i2213.
                        f20_ur_i2215 = f20_ur_i2215 + b-t-cif.i2215.
                        f20_ur_i2217 = f20_ur_i2217 + b-t-cif.i2217.
                        f20_ur_i2013 = f20_ur_i2013 + b-t-cif.i2013.
                        f20_ur_i2123 = f20_ur_i2123 + b-t-cif.i2123.
                        f20_ur_i2124 = f20_ur_i2124 + b-t-cif.i2124.
                        f20_ur_i2219 = f20_ur_i2219 + b-t-cif.i2219.
                        f20_ur_i2223 = f20_ur_i2223 + b-t-cif.i2223.
                        f20_ur_i2237 = f20_ur_i2237 + b-t-cif.i2237.
                        f20_ur_i2240 = f20_ur_i2240 + b-t-cif.i2240.
                    end.
                end.
                else if trim(b-t-cif.type) = "P" then do:
                    if i <= 10 then do:
                        f10_fiz_i2203 =  f10_fiz_i2203 + b-t-cif.i2203.
                        f10_fiz_i2204 =  f10_fiz_i2204 + b-t-cif.i2204.
                        f10_fiz_i2205 =  f10_fiz_i2205 + b-t-cif.i2205.
                        f10_fiz_i2206 =  f10_fiz_i2206 + b-t-cif.i2206.
                        f10_fiz_i2207 =  f10_fiz_i2207 + b-t-cif.i2207.
                        f10_fiz_i2213 =  f10_fiz_i2213 + b-t-cif.i2213.
                        f10_fiz_i2215 =  f10_fiz_i2215 + b-t-cif.i2215.
                        f10_fiz_i2217 =  f10_fiz_i2217 + b-t-cif.i2217.
                        f10_fiz_i2013 =  f10_fiz_i2013 + b-t-cif.i2013.
                        f10_fiz_i2123 =  f10_fiz_i2123 + b-t-cif.i2123.
                        f10_fiz_i2124 =  f10_fiz_i2124 + b-t-cif.i2124.
                        f10_fiz_i2237 =  f10_fiz_i2237 + b-t-cif.i2237.
                        f10_fiz_i2240 =  f10_fiz_i2240 + b-t-cif.i2240.
                    end.
                    if i <= 20 then do:
                        f20_fiz_i2203 = f20_fiz_i2203 + b-t-cif.i2203.
                        f20_fiz_i2204 = f20_fiz_i2204 + b-t-cif.i2204.
                        f20_fiz_i2205 = f20_fiz_i2205 + b-t-cif.i2205.
                        f20_fiz_i2206 = f20_fiz_i2206 + b-t-cif.i2206.
                        f20_fiz_i2207 = f20_fiz_i2207 + b-t-cif.i2207.
                        f20_fiz_i2213 = f20_fiz_i2213 + b-t-cif.i2213.
                        f20_fiz_i2215 = f20_fiz_i2215 + b-t-cif.i2215.
                        f20_fiz_i2217 = f20_fiz_i2217 + b-t-cif.i2217.
                        f20_fiz_i2013 = f20_fiz_i2013 + b-t-cif.i2013.
                        f20_fiz_i2123 = f20_fiz_i2123 + b-t-cif.i2123.
                        f20_fiz_i2124 = f20_fiz_i2124 + b-t-cif.i2124.
                        f20_fiz_i2237 = f20_fiz_i2237 + b-t-cif.i2237.
                        f20_fiz_i2240 = f20_fiz_i2240 + b-t-cif.i2240.
                    end.
                end.

                if i >= 20 then leave.
            end.
        end.
    end.
end.
/*------------------------------------------------*/
if v-urfiz = no then do:
    output to value(v-file).
    {html-title.i &size-add = "x-"}
end.
else do:
    if v-option = "mail" then output stream rep to value (vfname).
    else output stream rep to value (v-file2).
    {html-title.i &stream = "stream rep"}
end.

i = 0.
case v-sel2:

    when 5 then do:
        sum1 = f10_i2206 + f10_i2207 + f10_i2213.
        sum2 = f20_i2206 + f20_i2207 + f20_i2213.
        sum3 = s_i2206 + s_i2207 + s_i2213.
        sum4 = s_i2206 + s_i2207 + s_i2213.

        put unformatted
          "<P align=""center"" style=""font:bold"">Крупнейшие держатели срочных счетов ФЛ</P>" skip
          "<P align=""center"" style=""font:bold"">по состоянию на " string(v-dt, "99/99/9999") " года</P>" skip
          "<P align=""right"" style=""font:bold;font-size:8pt"">в тысячах тенге</P>"
          "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
              "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
                "<TD>#</TD>" skip
                "<TD>Филиал</TD>" skip
                "<TD>Наименование<br>клиента</TD>" skip
                "<TD>Вид<br>дея-<br>сти</TD>" skip
                "<TD>Остаток на срочных<br>счетах</TD>" skip
                "<TD>Доля в<br>клиентской<br>депо базе</TD>" skip
                "<TD>Доля в общей<br>депо базе</TD>" skip
              "</TR>" skip.
        for each t-cif no-lock. /*вытаскиваем клиентов c $ > 10%*/
           i = i + 1.
           put unformatted
             "<TR>" skip
               "<TD>" i "</TD>" skip
               "<TD>" t-cif.city "</TD>" skip
               "<TD>" t-cif.name "</TD>" skip
               "<TD>" t-cif.code "</TD>" skip
               "<TD>" replace(string((t-cif.sum / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
               "<TD>" replace(string((100 * t-cif.sum / sum3), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
               "<TD>" replace(string((100 * t-cif.sum / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
             "</TR>" skip.
            if i >= 20 then do:
               leave.
            end.
        end.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ВСЕГО ПО 10 КРУПНЕЙШИМ </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum1 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * sum1 / sum3), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * sum1 / sum4 ), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ВСЕГО ПО 20 КРУПНЕЙШИМ </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum2 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * sum2 / sum3), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * sum2 / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ВСЕГО НА СЧЕТАХ <br> КЛИЕНТОВ БАНКА </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum3 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string((100 * sum3 / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ОБЩАЯ ДЕПОЗИТНАЯ БАЗА <br> БАНКА </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum4 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD> </TD>" skip
            "<TD>100%</TD>" skip
          "</TR>" skip.


    end.


/*********************************************************************************************************/

    when 4 then do:
        sum1 = f10_i2204 + f10_i2205 + f10_i2213.
        sum2 = f20_i2204 + f20_i2205 + f20_i2213.
        sum3 = s_i2204 + s_i2205 + s_i2213.
        sum4 = s_i2204 + s_i2205 + s_i2213.

        put unformatted
          "<P align=""center"" style=""font:bold"">Крупнейшие держатели текущих счетов ФЛ</P>" skip
          "<P align=""center"" style=""font:bold"">по состоянию на " string(v-dt, "99/99/9999") " года</P>" skip
          "<P align=""right"" style=""font:bold;font-size:8pt"">в тысячах тенге</P>"
          "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
              "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
                "<TD>#</TD>" skip
                "<TD>Филиал</TD>" skip
                "<TD>Наименование<br>клиента</TD>" skip
                "<TD>Вид<br>дея-<br>сти</TD>" skip
                "<TD>Остаток на текущих<br>счетах</TD>" skip
                "<TD>Доля в<br>клиентской<br>депо базе</TD>" skip
                "<TD>Доля в общей<br>депо базе</TD>" skip
              "</TR>" skip.
        for each t-cif no-lock. /*вытаскиваем клиентов c $ > 10%*/
           i = i + 1.
           put unformatted
             "<TR>" skip
               "<TD>" i "</TD>" skip
               "<TD>" t-cif.city "</TD>" skip
               "<TD>" t-cif.name "</TD>" skip
               "<TD>" t-cif.code "</TD>" skip
               "<TD>" replace(string((t-cif.sum / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
               "<TD>" replace(string((100 * t-cif.sum / sum3), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
               "<TD>" replace(string((100 * t-cif.sum / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
             "</TR>" skip.
            if i >= 20 then do:
               leave.
            end.
        end.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ВСЕГО ПО 10 КРУПНЕЙШИМ </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum1 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * sum1 / sum3), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * sum1 / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ВСЕГО ПО 20 КРУПНЕЙШИМ </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum2 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * sum2 / sum3), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * sum2 / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ВСЕГО НА СЧЕТАХ <br> КЛИЕНТОВ БАНКА </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum3 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string((100 * sum3 / sum4 ), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ОБЩАЯ ДЕПОЗИТНАЯ БАЗА <br> БАНКА </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum4 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD> </TD>" skip
            "<TD>100%</TD>" skip
          "</TR>" skip.

    end.

/*********************************************************************************************************/

    when 3 then do:
        sum1 = f10_i2215 + f10_i2217 + f10_i2123 + f10_i2124.
        sum2 = f20_i2215 + f20_i2217 + f20_i2123 + f20_i2124.
        sum3 = s_i2215 + s_i2217.
        sum4 = s_i2215 + s_i2217 + s_i2123 + s_i2124.
        sum5 = s_i2123 + s_i2124.

        put unformatted
          "<P align=""center"" style=""font:bold"">Крупнейшие держатели срочных счетов ЮЛ</P>" skip
          "<P align=""center"" style=""font:bold"">по состоянию на " string(v-dt, "99/99/9999") " года</P>" skip
          "<P align=""right"" style=""font:bold;font-size:8pt"">в тысячах тенге</P>"
          "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
              "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
                "<TD>#</TD>" skip
                "<TD>Филиал</TD>" skip
                "<TD>Наименование<br>клиента</TD>" skip
                "<TD>Вид<br>дея-<br>сти</TD>" skip
                "<TD>Остаток на срочных<br>счетах</TD>" skip
                "<TD>Доля в<br>клиентской<br>депо базе</TD>" skip
                "<TD>Доля в общей<br>депо базе</TD>" skip
              "</TR>" skip.
        for each t-cif no-lock. /*вытаскиваем клиентов c $ > 10%*/
           i = i + 1.
           put unformatted
             "<TR>" skip
               "<TD>" i "</TD>" skip
               "<TD>" t-cif.city "</TD>" skip
               "<TD>" t-cif.name "</TD>" skip
               "<TD>" t-cif.code "</TD>" skip
               "<TD>" replace(string((t-cif.sum / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
               "<TD>" replace(string((100 * t-cif.sum / sum3), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
               "<TD>" replace(string((100 * t-cif.sum / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
             "</TR>" skip.
            if i >= 20 then do:
               leave.
            end.
        end.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ВСЕГО ПО 10 КРУПНЕЙШИМ </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum1 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * sum1 / sum3), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * sum1 / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ВСЕГО ПО 20 КРУПНЕЙШИМ </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum2 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * sum2 / sum3), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * sum2 / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ВСЕГО НА СЧЕТАХ <br> КЛИЕНТОВ БАНКА </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum3 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string((100 * sum3 / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ОБЩАЯ ДЕПОЗИТНАЯ БАЗА <br> БАНКА </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum4 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD> </TD>" skip
            "<TD>100%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> в т.ч. депозиты банков </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum5 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((100 * sum5 / sum4 ), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

    end.
/*********************************************************************************************************/

    when 2 then do:
        sum1 = f10_i2203 + f10_i2204 + f10_i2013.
        sum2 = f20_i2203 + f10_i2204 + f20_i2013.
        sum3 = s_i2203 + s_i2204.
        sum4 = s_i2203 + s_i2204 + s_i2013.
        sum5 = s_i2013.

        put unformatted
          "<P align=""center"" style=""font:bold"">Крупнейшие держатели текущих счетов ЮЛ</P>" skip
          "<P align=""center"" style=""font:bold"">по состоянию на " string(v-dt, "99/99/9999") " года</P>" skip
          "<P align=""right"" style=""font:bold;font-size:8pt"">в тысячах тенге</P>"
          "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
              "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
                "<TD>#</TD>" skip
                "<TD>Филиал</TD>" skip
                "<TD>Наименование<br>клиента</TD>" skip
                "<TD>Вид<br>дея-<br>сти</TD>" skip
                "<TD>Остаток на текущих<br>счетах</TD>" skip
                "<TD>Доля в<br>клиентской<br>депо базе</TD>" skip
                "<TD>Доля в общей<br>депо базе</TD>" skip
              "</TR>" skip.
        for each t-cif no-lock. /*вытаскиваем клиентов c $ > 10%*/
           i = i + 1.
           put unformatted
             "<TR>" skip
               "<TD>" i "</TD>" skip
               "<TD>" t-cif.city "</TD>" skip
               "<TD>" t-cif.name "</TD>" skip
               "<TD>" t-cif.code "</TD>" skip
               "<TD>" replace(string((t-cif.sum / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
               "<TD>" replace(string((100 * t-cif.sum / sum3), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
               "<TD>" replace(string((100 * t-cif.sum / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
             "</TR>" skip.
            if i >= 20 then do:
               leave.
            end.
        end.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ВСЕГО ПО 10 КРУПНЕЙШИМ </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum1 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * sum1 / sum3), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * sum1 / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ВСЕГО ПО 20 КРУПНЕЙШИМ </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum2 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * sum2 / sum3), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * sum2 / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ВСЕГО НА СЧЕТАХ <br> КЛИЕНТОВ БАНКА </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum3 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string((100 * sum3 / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> ОБЩАЯ ДЕПОЗИТНАЯ БАЗА <br> БАНКА </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum4 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD> </TD>" skip
            "<TD>100%</TD>" skip
          "</TR>" skip.

        put unformatted
          "<TR>" skip
            "<TD> </TD>" skip
            "<TD COLSPAN=2> в т.ч. депозиты банков </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum5 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((100 * sum5 / sum4), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
          "</TR>" skip.

    end.
/*********************************************************************************************************/
    when 1 then do:
        sum1_ur = f10_ur_i2203 + f10_ur_i2204 + f10_ur_i2213 + f10_ur_i2215 + f10_ur_i2217 + f10_ur_i2013 + f10_ur_i2123 + f10_ur_i2124 +
                  f10_ur_i2219 + f10_ur_i2223 + f10_ur_i2240 + f10_ur_i2237.

        sum2_ur = f20_ur_i2203 + f20_ur_i2204 + f20_ur_i2213 + f20_ur_i2215 + f20_ur_i2217 + f20_ur_i2013 + f20_ur_i2123 + f20_ur_i2124 +
                  f20_ur_i2219 + f20_ur_i2223 + f20_ur_i2240 + f20_ur_i2237.

        sum3_ur = s_ur_i2203 + s_ur_i2204 + s_ur_i2213 + s_ur_i2215 + s_ur_i2217 + s_ur_i2219 + s_ur_i2223 + s_ur_i2237 + s_ur_i2240.

        sum4_ur = s_ur_i2203 + s_ur_i2204 + s_ur_i2213 + s_ur_i2215 + s_ur_i2217 + s_ur_i2013 + s_ur_i2123 + s_ur_i2124 + s_ur_i2219 +
                  s_ur_i2223 + s_ur_i2240 + s_ur_i2237.

        sum5_ur = s_ur_i2013 + s_ur_i2123 + s_ur_i2124.

        put stream rep unformatted
          "<P align=""center"" style=""font:bold;font-size:10pt"">Концентрация депозитной базы ЮЛ</P>" skip
          "<P align=""center"" style=""font:bold;font-size:10pt"">по состоянию на " string(v-dt, "99/99/9999") " года</P>" skip
          "<P align=""right"" style=""font:bold;font-size:8pt"">в тысячах тенге</P>"
          "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
              "<TR align=""center"" style=""font:bold;font-size:10pt"">" skip
                "<TD>#</TD>" skip
                "<TD>Филиал</TD>" skip
                "<TD>Наименование<br>клиента</TD>" skip
                "<TD>Вид<br>дея-<br>сти</TD>" skip
                "<TD>Остаток на всех<br>счетах клиента</TD>" skip
                "<TD>Доля в<br>клиентской<br>депо базе</TD>" skip
                "<TD>Доля в общей<br>депо базе</TD>" skip
                "<TD>в т.ч. на<br>текущих<br>счетах</TD>" skip
                "<TD>Доля в<br>клиентской<br>депо базе</TD>" skip
                "<TD>Доля в общей<br>депо базе</TD>" skip
                "<TD>в т.ч. на<br>срочных<br>счетах</TD>" skip
                "<TD>Доля в<br>клиентской<br>депо базе</TD>" skip
                "<TD>Доля в общей<br>депо базе</TD>" skip
              "</TR>" skip.

        i = 0.
        for each t-cif use-index sum no-lock:
            if t-cif.type = "B" then do:
                i = i + 1.
                put stream rep unformatted
                "<TR align=center style='font-size:10pt'>" skip
                "<TD>" i "</TD>" skip
                "<TD align=left>" t-cif.city "</TD>" skip
                "<TD align=left>" t-cif.name "</TD>" skip
                "<TD>" t-cif.code "</TD>" skip
                "<TD>" replace(string((t-cif.sum / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
                "<TD>" replace(string((100 * t-cif.sum  / sum3_ur), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
                "<TD>" replace(string((100 * t-cif.sum  / sum4_ur), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
                "<TD>" replace(string(((t-cif.i2203 + t-cif.i2204 + t-cif.i2013 + t-cif.i2237) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
                "<TD>" replace(string((100 * (t-cif.i2203 + t-cif.i2204 + t-cif.i2013) / (s_ur_i2203 + s_ur_i2204)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
                "<TD>" replace(string((100 * (t-cif.i2203 + t-cif.i2204 + t-cif.i2013) / (s_ur_i2203 + s_ur_i2204 + s_ur_i2013)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
                "<TD>" replace(string(((t-cif.i2215 + t-cif.i2217 + t-cif.i2213 + t-cif.i2123 + t-cif.i2124 + t-cif.i2219 + t-cif.i2223 + t-cif.i2240) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
                "<TD>" replace(string((100 * (t-cif.i2215 + t-cif.i2217 + t-cif.i2123 + t-cif.i2124) / (s_ur_i2215 + s_ur_i2217)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
                "<TD>" replace(string((100 * (t-cif.i2215 + t-cif.i2217 + t-cif.i2123 + t-cif.i2124) / (s_ur_i2215 + s_ur_i2217 + s_ur_i2123 + s_ur_i2124)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
                "</TR>" skip.
                if i >= 20 then leave.
            end.
        end.
        put stream rep unformatted
            "<TR align=center style='font-size:10pt'>" skip
            "<TD></TD>" skip
            "<TD align=left colspan=2> ВСЕГО ПО 10 КРУПНЕЙШИМ </TD>" skip
            "<TD></TD>" skip
            "<TD>" replace(string((sum1_ur / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * sum1_ur / sum3_ur), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * sum1_ur / sum4_ur), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string(((f10_ur_i2203 + f10_ur_i2204 + f10_ur_i2013 + f10_ur_i2237) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * (f10_ur_i2203 + f10_ur_i2204 + f10_ur_i2013) / (s_ur_i2203 + s_ur_i2204)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * (f10_ur_i2203 + f10_ur_i2204 + f10_ur_i2013) / (s_ur_i2203 + s_ur_i2204 + s_ur_i2013) ), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string(((f10_ur_i2215 + f10_ur_i2217 + f10_ur_i2213 + f10_ur_i2123 + f10_ur_i2124 + f10_ur_i2219 + f10_ur_i2223 + f10_ur_i2240) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * (f10_ur_i2215 + f10_ur_i2217 + f10_ur_i2123 + f10_ur_i2124) / (s_ur_i2215 + s_ur_i2217)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * (f10_ur_i2215 + f10_ur_i2217 + f10_ur_i2123 + f10_ur_i2124) / (s_ur_i2215 + s_ur_i2217 + s_ur_i2123 + s_ur_i2124)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "</TR>" skip.

        put stream rep unformatted
            "<TR align=center style='font-size:10pt'>" skip
            "<TD></TD>" skip
            "<TD align=left colspan=2> ВСЕГО ПО 20 КРУПНЕЙШИМ </TD>" skip
            "<TD></TD>" skip
            "<TD>" replace(string((sum2_ur / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * sum2_ur / sum3_ur), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * sum2_ur / sum4_ur), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string(((f20_ur_i2203 + f20_ur_i2204 + f20_ur_i2013 + f20_ur_i2237) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * (f20_ur_i2203 + f20_ur_i2204 + f20_ur_i2013) / (s_ur_i2203 + s_ur_i2204)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * (f20_ur_i2203 + f20_ur_i2204 + f20_ur_i2013) / (s_ur_i2203 + s_ur_i2204 + s_ur_i2013)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string(((f20_ur_i2215 + f20_ur_i2217 + f20_ur_i2213 + f20_ur_i2123 + f20_ur_i2124 + f20_ur_i2219 + f20_ur_i2223 + f20_ur_i2240) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * (f20_ur_i2215 + f20_ur_i2217 + f20_ur_i2123 + f20_ur_i2124) / (s_ur_i2215 + s_ur_i2217)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * (f20_ur_i2215 + f20_ur_i2217 + f20_ur_i2123 + f20_ur_i2124) / (s_ur_i2215 + s_ur_i2217 + s_ur_i2123 + s_ur_i2124)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "</TR>" skip.

        put stream rep unformatted
            "<TR align=center style='font-size:10pt'>" skip
            "<TD></TD>" skip
            "<TD align=left colspan=2> ВСЕГО НА СЧЕТАХ <br> КЛИЕНТОВ БАНКА </TD>" skip
            "<TD></TD>" skip
            "<TD>" replace(string((sum3_ur / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string((100 * sum3_ur / sum4_ur), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string(((s_ur_i2203 + s_ur_i2204 + s_ur_i2237) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string((100 * (s_ur_i2203 + s_ur_i2204) / (s_ur_i2203 + s_ur_i2204 + s_ur_i2013)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string(((s_ur_i2215 + s_ur_i2217 + s_ur_i2213 + s_ur_i2219 + s_ur_i2223 + s_ur_i2240) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string((100 * (s_ur_i2215 + s_ur_i2217) / (s_ur_i2215 + s_ur_i2217 + s_ur_i2123 + s_ur_i2124)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "</TR>" skip.

        put stream rep unformatted
            "<TR align=center style='font-size:10pt'>" skip
            "<TD></TD>" skip
            "<TD align=left colspan=2> ОБЩАЯ ДЕПОЗИТНАЯ БАЗА <br> БАНКА </TD>" skip
            "<TD></TD>" skip
            "<TD>" replace(string((sum4_ur / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD></TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string(((s_ur_i2203 + s_ur_i2204 + s_ur_i2013 + s_ur_i2237) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD></TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string(((s_ur_i2215 + s_ur_i2217 + s_ur_i2213 + s_ur_i2123 + s_ur_i2124 + s_ur_i2219 + s_ur_i2223 + s_ur_i2240) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD></TD>" skip
            "<TD>100%</TD>" skip
            "</TR>" skip.

        put stream rep unformatted
            "<TR align=center style='font-size:10pt'>" skip
            "<TD></TD>" skip
            "<TD align=left colspan=2> в т.ч. депозиты банков </TD>" skip
            "<TD></TD>" skip
            "<TD>" replace(string((sum5_ur / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD></TD>" skip
            "<TD>" replace(string((100 * sum5_ur / sum4_ur), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((s_ur_i2013 / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD></TD>" skip
            "<TD>" replace(string((100 * s_ur_i2013 / (s_ur_i2203 + s_ur_i2204 + s_ur_i2013)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string(((s_ur_i2123 + s_ur_i2124) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD></TD>" skip
            "<TD>" replace(string((100 * (s_ur_i2123 + s_ur_i2124) / (s_ur_i2215 + s_ur_i2217 + s_ur_i2123 + s_ur_i2124)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "</TR>" skip.

        put stream rep unformatted
            "</TABLE>" skip.

    /***************************************************************/

        sum1_fiz = f10_fiz_i2204 + f10_fiz_i2205 + f10_fiz_i2206 + f10_fiz_i2207 + f10_fiz_i2213 + f10_fiz_i2237 + f10_fiz_i2240.
        sum2_fiz = f20_fiz_i2204 + f20_fiz_i2205 + f20_fiz_i2206 + f20_fiz_i2207 + f20_fiz_i2213 + f10_fiz_i2237 + f20_fiz_i2240.
        sum3_fiz = s_fiz_i2204 + s_fiz_i2205 + s_fiz_i2206 + s_fiz_i2207 + s_fiz_i2213 + s_fiz_i2237 + s_fiz_i2240.
        sum4_fiz = s_fiz_i2204 + s_fiz_i2205 + s_fiz_i2206 + s_fiz_i2207 + s_fiz_i2213 + s_fiz_i2237 + s_fiz_i2240.

        put stream rep unformatted
          "<P align=""center"" style=""font:bold;font-size:10pt"">Концентрация депозитной базы ФЛ</P>" skip
          "<P align=""center"" style=""font:bold;font-size:10pt"">по состоянию на " string(v-dt, "99/99/9999") " года</P>" skip
          "<P align=""right"" style=""font:bold;font-size:8pt"">в тысячах тенге</P>"
          "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
              "<TR align=""center"" style=""font:bold;font-size:10pt"">" skip
                "<TD>#</TD>" skip
                "<TD>Филиал</TD>" skip
                "<TD>Наименование<br>клиента</TD>" skip
                "<TD>Вид<br>дея-<br>сти</TD>" skip
                "<TD>Остаток на всех<br>счетах клиента</TD>" skip
                "<TD>Доля в<br>клиентской<br>депо базе</TD>" skip
                "<TD>Доля в общей<br>депо базе</TD>" skip
                "<TD>в т.ч. на<br>текущих<br>счетах</TD>" skip
                "<TD>Доля в<br>клиентской<br>депо базе</TD>" skip
                "<TD>Доля в общей<br>депо базе</TD>" skip
                "<TD>в т.ч. на<br>срочных<br>счетах</TD>" skip
                "<TD>Доля в<br>клиентской<br>депо базе</TD>" skip
                "<TD>Доля в общей<br>депо базе</TD>" skip
              "</TR>" skip.

        i = 0.
        for each t-cif use-index sum no-lock:
            if t-cif.type = "P" then do:
                i = i + 1.
                put stream rep unformatted
                "<TR align=center style='font-size:10pt'>" skip
                "<TD>" i "</TD>" skip
                "<TD align=left>" t-cif.city "</TD>" skip
                "<TD align=left>" t-cif.name "</TD>" skip
                "<TD>" t-cif.code "</TD>" skip
                "<TD>" replace(string((t-cif.sum / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
                "<TD>" replace(string((100 * t-cif.sum / sum3_fiz), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
                "<TD>" replace(string((100 * t-cif.sum / sum4_fiz), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
                "<TD>" replace(string(((t-cif.i2204 + t-cif.i2205 + t-cif.i2237) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
                "<TD>" replace(string((100 * (t-cif.i2204 + t-cif.i2205) / (s_fiz_i2204 + s_fiz_i2205)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
                "<TD>" replace(string((100 * (t-cif.i2204 + t-cif.i2205) / (s_fiz_i2204 + s_fiz_i2205)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
                "<TD>" replace(string(((t-cif.i2206 + t-cif.i2207 + t-cif.i2213 + t-cif.i2240) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
                "<TD>" replace(string((100 * (t-cif.i2206 + t-cif.i2207 + t-cif.i2213) / (s_fiz_i2206 + s_fiz_i2207 + s_fiz_i2213)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
                "<TD>" replace(string((100 * (t-cif.i2206 + t-cif.i2207 + t-cif.i2213) / (s_fiz_i2206 + s_fiz_i2207 + s_fiz_i2213)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
                "</TR>" skip.
                if i >= 20 then leave.
            end.
        end.
        put stream rep unformatted
            "<TR align=center style='font-size:10pt'>" skip
            "<TD></TD>" skip
            "<TD align=left colspan=""2""> ВСЕГО ПО 10 КРУПНЕЙШИМ </TD>" skip
            "<TD></TD>" skip
            "<TD>" replace(string((sum1_fiz / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * sum1_fiz / sum3_fiz), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * sum1_fiz / sum4_fiz), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string(((f10_fiz_i2204 + f10_fiz_i2205 + f10_fiz_i2237) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * (f10_fiz_i2204 + f10_fiz_i2205) / (s_fiz_i2204 + s_fiz_i2205)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * (f10_fiz_i2204 + f10_fiz_i2205) / (s_fiz_i2204 + s_fiz_i2205)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string(((f10_fiz_i2206 + f10_fiz_i2207 + f10_fiz_i2213 + f10_fiz_i2240) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * (f10_fiz_i2206 + f10_fiz_i2207 + f10_fiz_i2213) / (s_fiz_i2206 + s_fiz_i2207 + s_fiz_i2213)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * (f10_fiz_i2206 + f10_fiz_i2207 + f10_fiz_i2213) / (s_fiz_i2206 + s_fiz_i2207 + s_fiz_i2213)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "</TR>" skip.

        put stream rep unformatted
            "<TR align=center style='font-size:10pt'>" skip
            "<TD></TD>" skip
            "<TD align=left colspan=""2""> ВСЕГО ПО 20 КРУПНЕЙШИМ </TD>" skip
            "<TD> </TD>" skip
            "<TD>" replace(string((sum2_fiz / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * sum2_fiz / sum3_fiz), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * sum2_fiz / sum4_fiz), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string(((f20_fiz_i2204 + f20_fiz_i2205 + f20_fiz_i2237) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * (f20_fiz_i2204 + f20_fiz_i2205) / (s_fiz_i2204 + s_fiz_i2205)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * (f20_fiz_i2204 + f20_fiz_i2205) / (s_fiz_i2204 + s_fiz_i2205)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string(((f20_fiz_i2206 + f20_fiz_i2207 + f20_fiz_i2213 + f20_fiz_i2240) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>" replace(string((100 * (f20_fiz_i2206 + f20_fiz_i2207 + f20_fiz_i2213) / (s_fiz_i2206 + s_fiz_i2207 + s_fiz_i2213)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string((100 * (f20_fiz_i2206 + f20_fiz_i2207 + f20_fiz_i2213) / (s_fiz_i2206 + s_fiz_i2207 + s_fiz_i2213)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "</TR>" skip.

        put stream rep unformatted
            "<TR align=center style='font-size:10pt'>" skip
            "<TD></TD>" skip
            "<TD align=left colspan=""2""> ВСЕГО НА СЧЕТАХ <br> КЛИЕНТОВ БАНКА </TD>" skip
            "<TD></TD>" skip
            "<TD>" replace(string((sum3_fiz / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string(((100 / sum4_fiz) * sum3_fiz ), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string(((s_fiz_i2204 + s_fiz_i2205 + s_fiz_i2237) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string((100 * (s_fiz_i2204 + s_fiz_i2205) / (s_fiz_i2204 + s_fiz_i2205)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "<TD>" replace(string(((s_fiz_i2206 + s_fiz_i2207 + s_fiz_i2213 + s_fiz_i2240) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string((100 * (s_fiz_i2206 + s_fiz_i2207 + s_fiz_i2213) / (s_fiz_i2206 + s_fiz_i2207 + s_fiz_i2213)), "->>>>>>>>>>>9.99"), ".", ",") "%</TD>" skip
            "</TR>" skip.

        put stream rep unformatted
            "<TR align=center style='font-size:10pt'>" skip
            "<TD></TD>" skip
            "<TD align=left colspan=""2""> ОБЩАЯ ДЕПОЗИТНАЯ БАЗА <br> БАНКА </TD>" skip
            "<TD></TD>" skip
            "<TD>" replace(string((sum4_fiz / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD></TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string(((s_fiz_i2204 + s_fiz_i2205 + s_fiz_i2237) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD></TD>" skip
            "<TD>100%</TD>" skip
            "<TD>" replace(string(((s_fiz_i2206 + s_fiz_i2207 + s_fiz_i2213 + s_fiz_i2240) / 1000), "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD></TD>" skip
            "<TD>100%</TD>" skip
            "</TR>" skip.
    end.
end case.

if v-urfiz = no then do:
    put unformatted
        "</TABLE>" skip.

    {html-end.i " "}
    output close.
end.
else do:
    put stream rep unformatted
        "</TABLE>" skip.

    {html-end.i "stream rep"}
    output stream rep close.
end.

hide all.

if v-option <> "mail" then do:
    if v-urfiz = no then unix silent cptwin value(v-file) excel.
    else unix silent cptwin value(v-file2) excel.
end.
pause 0.
vres = yes.

