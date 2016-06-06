/* kdhold.p Электронное кредитное досье

 * MODULE
     Кредитный модуль
 * DESCRIPTION
       Список залогодателей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
       
 * AUTHOR
        14.01.2004 marinav
 * CHANGES
        30/04/2004 madiar - просмотр досье филиалов в ГБ
        17/05/2004 madiar - исправил ошибку при просмотре досье филиалов в ГБ
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
        30.09.2005 marinav - изменения для бизнес-кредитов
        14/10/2005 madiar - добавил признак юр/физ для залогодателя
        22/10/2005 madiar - добавил должность руководителя для залогодателя
    05/09/06   marinav - добавление индексов
*/



{global.i}
{kd.i}
{pksysc.f}

if s-kdlon = '' then return.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

define var v-zal as char extent 20.

define frame fr skip(1)
       kdaffil.info[5] format "x(50)" label "Должность рук-ля" skip
       kdaffil.info[2] format "x(50)" label "ФИО руководителя" skip
       kdaffil.info[3] format "x(50)"  label "Гл. бухгалтер   " skip
       "Учредители :" skip
       v-zal[1] format "x(55)" no-label v-zal[2] format "x(3)" no-label "%"  skip
       v-zal[3] format "x(55)" no-label v-zal[4] format "x(3)" no-label "%"  skip
       v-zal[5] format "x(55)" no-label v-zal[6] format "x(3)" no-label "%"  skip
       v-zal[7] format "x(55)" no-label v-zal[8] format "x(3)" no-label "%"  skip
       v-zal[9] format "x(55)" no-label v-zal[10] format "x(3)" no-label "%"  skip
       v-zal[11] format "x(55)" no-label v-zal[12] format "x(3)" no-label "%"  skip
       v-zal[13] format "x(55)" no-label v-zal[14] format "x(3)" no-label  "%" skip
       v-zal[15] format "x(55)" no-label v-zal[16] format "x(3)" no-label "%" skip
       kdaffil.whn      label "ПРОВЕДЕНО " kdaffil.who  no-label skip(1)
       with overlay width 73 side-labels centered row 3
       title "ИНФОРМАЦИЯ О ЗАЛОГОДАТЕЛЕ" .

define variable s_rowid as rowid.
define var v-ln as inte init 1.
define var i as inte.

{jabrw.i 
&start     = " "
&head      = "kdaffil"
&headkey   = "code"
&index     = "cifnomc"

&formname  = "pksysc"
&framename = "kdaffil22"
&where     = " kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '22' "

&addcon    = "(kdlon.bank = s-ourbank)"
&deletecon = "(kdlon.bank = s-ourbank)"
&precreate = " "
&postadd   = "  s_rowid = rowid(kdaffil). find last kdaffil where kdaffil.code = '22' and kdaffil.kdcif = s-kdcif
                and kdaffil.kdlon = s-kdlon no-lock no-error. if avail kdaffil then v-ln = kdaffil.ln + 1.
                find kdaffil where rowid(kdaffil) = s_rowid.
                kdaffil.ln = v-ln. kdaffil.bank = s-ourbank. kdaffil.code = '22'. kdaffil.kdcif = s-kdcif.
                kdaffil.kdlon = s-kdlon.  kdaffil.who = g-ofc. kdaffil.whn = g-today. displ kdaffil.ln with frame kdaffil22 .
                update kdaffil.info[4] kdaffil.name kdaffil.datres[1] kdaffil.datres[2] kdaffil.res with frame kdaffil22 .
                message 'F1 - Сохранить, F4 - Выход без сохранения'.
                do i = 1 to extent(v-zal): v-zal[i] = ''. end.
                displ kdaffil.info[5] kdaffil.info[2] kdaffil.info[3] v-zal[1] v-zal[2] v-zal[3] v-zal[4] v-zal[5]
                v-zal[6] v-zal[7] v-zal[8] v-zal[9] v-zal[10] v-zal[11] v-zal[12] v-zal[13] v-zal[14]
                v-zal[15] v-zal[16]  kdaffil.whn  kdaffil.who with frame fr.
                update kdaffil.info[5] kdaffil.info[2] kdaffil.info[3] v-zal[1] v-zal[2] v-zal[3] v-zal[4] v-zal[5]
                v-zal[6] v-zal[7] v-zal[8] v-zal[9] v-zal[10] v-zal[11] v-zal[12] v-zal[13] v-zal[14]
                v-zal[15] v-zal[16] with frame fr. do i = 1 to extent(v-zal): kdaffil.info[1] = kdaffil.info[1] + trim(v-zal[i]) + ','. end. "
                 
&prechoose = " message 'F4-Выход,   INS-Вставка.'."

&postdisplay = " "

&display   = " kdaffil.ln kdaffil.info[4] kdaffil.name kdaffil.datres[1] kdaffil.datres[2] kdaffil.res  "

&highlight = " kdaffil.ln kdaffil.info[4] kdaffil.name "


&postkey   = "else
              if keyfunction(lastkey) = 'RETURN'
              then do transaction on endkey undo, leave:
                if kdlon.bank = s-ourbank then do:
                   update kdaffil.info[4] kdaffil.name kdaffil.datres[1] kdaffil.datres[2] kdaffil.res with frame kdaffil22.
                   message 'F1 - Сохранить, F4 - Выход без сохранения'.
                end.
                do i = 1 to extent(v-zal): v-zal[i] = ''. end.
                do i = 1 to extent(v-zal): v-zal[i] = entry(i, kdaffil.info[1]). end.
                displ kdaffil.info[5] kdaffil.info[2] kdaffil.info[3] v-zal[1] v-zal[2] v-zal[3] v-zal[4] v-zal[5]
                      v-zal[6] v-zal[7] v-zal[8] v-zal[9] v-zal[10] v-zal[11] v-zal[12] v-zal[13] v-zal[14]
                      v-zal[15] v-zal[16]  kdaffil.whn  kdaffil.who with frame fr.
                if kdlon.bank = s-ourbank then do:
                   update kdaffil.info[5] kdaffil.info[2] kdaffil.info[3] v-zal[1] v-zal[2] v-zal[3] v-zal[4] v-zal[5]
                   v-zal[6] v-zal[7] v-zal[8] v-zal[9] v-zal[10] v-zal[11] v-zal[12] v-zal[13] v-zal[14]
                   v-zal[15] v-zal[16] with frame fr.
                   kdaffil.who = g-ofc. kdaffil.whn = g-today. hide frame fr no-pause. kdaffil.info[1] = ''.
                   do i = 1 to extent(v-zal): kdaffil.info[1] = kdaffil.info[1] + trim(v-zal[i]) + ','. end.
                end.
                else do:
                   pause.
                   hide frame fr no-pause.
                end.
              end. "

&end = "hide frame kdaffil22.
         hide frame fr."
}
hide message.
