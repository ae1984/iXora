/* vcpartners.f
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Форма редактирования справочника инопартнеров
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
        18.10.2002 nadejda
 * CHANGES
        26.08.2003 nadejda - добавлена проверка орг-прав.формы по справочнику
        24.04.2008 galina - добавлено поле СЕКТОР ЭКОНОМИКИ;
                            выбор значения поля из справочника;
                            проверка соотвествия значения поля справочнику
        30.04.2008 galina -  исправлено наименование поля info[2]
        02.07.2008 galina - присваиваем полю СЕКТОР ЭКОНОМИКИ значение из спарвочника, а не номер по порядку
        07/10/2010 aigul - Увеличила на 100 символов поле "НАЗВАН"

*/


def var msg-err as char.
def var v-sel as integer no-undo.
def var v-secek as char no-undo.

function chk-prefix returns logical (p-value as char).
  if not can-find(codfr where codfr.codfr = "ownform" and codfr.code = p-value and
        codfr.code <> "msc" no-lock) then do:
    message skip
         " Введенное краткое название организационно-правовой формы " skip
         " НЕ НАЙДЕНО В СПРАВОЧНИКЕ !" skip(1)
         " Добавить в справочник новое значение ? " skip(1)
         view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-choice as logical.
    if v-choice then do:
      create codfr.
      codfr.codfr = "ownform".
      codfr.level = 1.
      codfr.code = p-value.
      codfr.tree-node  = "ownform" + caps(codfr.code).
      return true.
    end.
    else do:
      msg-err = " Нет такого кода в справочнике организационно-правовых форм !".
      return false.
    end.
  end.
  return true.
end.

form skip(1)
  vcpartners.partner label "КОД ПАРТНЕРА"  skip(1)
  vcpartners.formasob format "x(20)" label "ФОРМА СОБСТВ."
     help " F2 - справочник организационно-правовых форм "
     validate(chk-prefix (vcpartners.formasob), msg-err)
  vcpartner.info[2] format 'x(3)' LABEL "СЕКТОР ЭКОНОМИКИ" validate(can-find (codfr where codfr.codfr = "secek" and codfr.code = vcpartners.info[2] no-lock),
              " Нет такого кода сектора экономики!") colon 60 skip(1)

  vcpartners.name format "x(100)" label "НАЗВАН"
    validate(vcpartners.name <> "", " Введите наименование фирмы-инопартнера!") skip(1)
  vcpartners.country
    validate (can-find (codfr where codfr.codfr = "iso3166" and codfr.code = vcpartners.country no-lock),
              " Нет такого кода страны в справочнике стран!")
    skip
  vcpartners.address  skip
  vcpartners.bankdata  skip(1)
  vcpartners.rdt LABEL "ДАТА РЕГ."  vcpartners.cdt colon 60 skip
  vcpartners.rwho LABEL "ЗАРЕГИСТРИРОВАЛ"  vcpartners.cwho colon 60 skip(1)
  vcpartners.info[1] LABEL "ПРИМЕЧАНИЕ"  skip(1)


with side-label row 3 width 110 frame vcpartners.

on help of vcpartners.info[2] in frame vcpartners do:
if v-secek = "" then do:
 for each codfr where codfr.codfr = 'secek' and codfr.code <> 'msc' no-lock:
  if v-secek <> "" then v-secek = v-secek + " |".
  v-secek = v-secek + string(codfr.code) + " " + codfr.name[1].
 end.
end.
    v-sel = 0.
    run sel2 ("СЕКТОР ЭКОНОМИКИ ", v-secek, output v-sel).
    vcpartners.info[2] = trim(entry(1,(entry(v-sel,v-secek, '|')),' ')).
    display vcpartners.info[2] with frame vcpartners.
end.

