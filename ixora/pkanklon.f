/* pkanklon.f
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
*/

/* pkanklon.f ПотребКредит
   Форма анкеты к Операциям по кредиту

   05.02.2003 nadejda
   13.06.2003 nadejda - добавила заголовок фрейма по виду кредитов
   28.01.2004 sasco можно вводить пустого партнера для типа "6"
   19.04.2006 Natalya D. - добавила изменения для Подарочной карточки (credtype - 9)
   29/05/2006 madiyar - v-anktype (повторная, рефинансирование, казпочта)
   19.02.10   marinav - формат счета 20
   11/05/2010 galina - добавила поля "Статус КД" и "Дата стат.КД"
   17/06/2010 galina - добавила поле "Поручитель"
*/

def var v-refusname as char format "x(40)".
def var v-stsdescr as char.
def var v-predpr as char.
def var v-sts as char.
def var v-crccod1 as char format "xxx".
def var v-crccod2 as char format "xxx".
def var v-crccod3 as char format "xxx".
def var v-crccod4 as char format "xxx".
def var v-crccod5 as char format "xxx".
def var v-msgerr as char.
def var v-pkpartner as char.
def var v-credname as char.
def var v-jhcomiss as integer.
def var v-labelcomiss as char.
def var v-anktype as char.
def var v-kdsts as char.
def var v-kddt as date.
def var v-kdstsdes as char.
def var v-kdguaran as char.

find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.
v-credname = bookcod.name.

function checkpartn returns logical (p-value as char, output p-msg as char).

  if p-value = "" then return true.

/*  if p-value = "" then do:
    p-msg = " Обязательная информация - пустая строка не допускается !".
    return false.
  end.
 */
  if (s-credtype ne "4") and (s-credtype ne "9") then do:

    find codfr where codfr.codfr = "pkpartn" and codfr.code = p-value no-lock no-error.
    if not avail codfr or lookup (s-credtype, codfr.name[5]) = 0 then do:
      p-msg = " Указанный счет не найден в справочнике предприятий партнеров!".
      return false.
    end.

    if codfr.name[4] = "" then do:
      find aaa where aaa.aaa = p-value no-lock no-error.
      if avail aaa and aaa.sta = "c" then do:
        p-msg = " Счет закрыт!".
        return false.
      end.
    end.

  end.

  if s-credtype = "4" or s-credtype = '9' then do:
    find bookcod where bookcod.bookcod = "kktype" and bookcod.code = p-value no-lock no-error.
    if not avail bookcod then do:
      p-msg = " Такой код в справочнике отсутствует!".
      return false.
    end.
  end.

  return true.
end.

form
  s-pkankln label "НОМЕР АНКЕТЫ"
    help " F2 - поиск"
    validate (can-find(pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
                       pkanketa.ln = s-pkankln no-lock), " Анкета с номером " + string(s-pkankln) + " не найдена !")
                       colon 15
    v-anktype format "x(11)" no-label
           pkanketa.rdt label "РЕГИСТР" colon 54
           pkanketa.rwho no-label colon 69 skip

  pkanketa.rating label "РЕЙТИНГ АНКЕТЫ" colon 15
           pkanketa.cdt label  "КОНТРОЛ" colon 54
           pkanketa.cwho no-label colon 69 skip

  pkanketa.sts label "СТАТУС" colon 15
    help " F2 - справочник"
    validate (pkanketa.sts <> "msc" and can-find (bookcod where bookcod.bookcod = "pkstsank" and
              bookcod.code = pkanketa.sts no-lock), " Неверный статус !")
  v-stsdescr no-label format "x(40)" colon 20 skip

  pkanketa.rnn label "РНН" colon 15
           pkanketa.bank format "x(6)" label "БАНК" colon 69 skip
  pkanketa.name label "ФИО КЛИЕНТА" colon 15 skip
  pkanketa.refusal format "x(50)" label "ПРИЧИНА ОТКАЗА" colon 15 skip(1)

  pkanketa.summax format "zzz,zzz,zz9.99" label "МАКС.СУММА" colon 15 v-crccod1 no-label
           pkanketa.sumavans format "zzz,zzz,zz9.99" label "АВАНС.ВЗНОС" colon 54 v-crccod5 no-label colon 69 skip
  pkanketa.sumq format "zzz,zzz,zz9.99" label "СУММА ЗАПРОСА" colon 15 v-crccod2 no-label
           pkanketa.sumavans% format ">>>9.99" label "АВАНС.ВЗНОС %" colon 54 skip
  pkanketa.summa format "zzz,zzz,zz9.99" label "СУММА КРЕДИТА" colon 15 v-crccod3 no-label
           lon.day format ">9" label "ДЕНЬ ПОГАШЕНИЯ" colon 54
           lon.lcr format "x" label "АВТО/РУЧ" colon 69 help " A - автоматическое погашение, M - менеджером Департамента"
           validate (lookup(lon.lcr, "a,m,A,M") > 0 , " Введен недопустимый символ !") skip
  pkanketa.srokmin label "МИН.СРОК" colon 15 "мес." colon 19
           pkanketa.cif label "КОД КЛИЕНТА" colon 54 skip
  pkanketa.srok label "СРОК КРЕДИТА" colon 15 "мес." colon 19
           pkanketa.lon label "ССУДНЫЙ СЧЕТ" colon 54 skip
  pkanketa.duedt format "99/99/9999" label "ДАТА ОКОНЧ" colon 15
           pkanketa.aaa format "x(21)" label "ТЕК.СЧЕТ (ТЕНГЕ/ВАЛ)" colon 54
           pkanketa.aaaval format "x(9)" colon 66 no-label skip
  pkanketa.rateq label "ПРОЦЕНТ" format ">>>9.9999" colon 15
           pkanketa.trx1 format ">>>>>>>9" label "ПРОВОДКА-ВЫДАЧА" colon 54
           v-labelcomiss format "x(5)" no-label colon 63
           v-jhcomiss format ">>>>>>>9" no-label colon 69 skip
  pkanketa.billsum format "zzz,zzz,zz9.99" label "СТОИМОСТЬ" colon 15
    help " Введите цену приобретения"
    validate (pkanketa.billsum <> 0, " Обязательная информация - 0 не допускается !")
           /*v-crccod4 no-label*/
           pkanketa.trx2 format ">>>>>>>>9" label "ПРОВОДКА-ПЕРЕВОД" colon 54
           pkanketa.sernom format "x(10)" no-label colon 66 skip
  pkanketa.goal label "ЦЕЛЬ КРЕДИТА" colon 15
    help " Введите наименование товара"
    validate (pkanketa.goal <> "", " Обязательная информация - пустая строка не допускается !") skip
  v-pkpartner label "ПРЕДПРИЯТИЕ" format "x(10)" colon 15
    help " F2 - справочник"
    validate (checkpartn(v-pkpartner, output v-msgerr), v-msgerr)
  v-predpr format "x(45)" no-label colon 26 skip
  v-kdsts label "СТАТУС КД" format "x(3)" colon 15 help "Введите Статус КД" validate(can-find( codfr where codfr.codfr = 'kdsts' and codfr.code = v-kdsts no-lock), 'Неверное значение!')
  v-kdstsdes no-label format "x(61)" colon 19 skip
  v-kddt format "99/99/9999" label "ДАТА СТАТ.КД" colon 15 help "Введите дату Статуса КД" validate(v-kddt <> ?,'Введите дату') skip
  v-kdguaran label 'ПОРУЧИТЕЛЬ' format "x(61)" colon 15 skip
  with centered row 3 width 85 side-labels title v-credname frame pkank.

form
  pkanketa.billnom label " СОГЛАСНО" format "x(50)"
    help " Введите название документа"
    validate (pkanketa.billnom <> "", " Обязательная информация - пустая строка не допускается !")
  " " skip
  with centered overlay row 15 side-label title " ДОПОЛНИТЕЛЬНЫЕ СВЕДЕНИЯ " frame f-dop.


on help of pkanketa.sts in frame pkank do:
  v-sts = pkanketa.sts.
  run uni_book ("pkstsank", "*", output v-sts).
  pkanketa.sts = entry(1, v-sts).
  frame-value = pkanketa.sts.
end.

on help of v-kdsts in frame pkank do:
  {itemlist.i
    &file = "codfr"
    &frame = "row 6 centered scroll 1 20 down overlay width 91 "
    &where = " codfr.codfr = 'kdsts' "
    &flddisp = " codfr.code label 'Код' format 'x(8)' codfr.name[1] label 'Значение' format 'x(80)' "
    &chkey = "code"
    &index  = "cdco_idx"
    &end = "if keyfunction(lastkey) = 'end-error' then return."
}
   v-kdsts = codfr.code.
   displ v-kdsts with frame pkank.
end.


on help of lon.lcr in frame pkank do: pause 0. end.


v-labelcomiss = "КОМ:".
