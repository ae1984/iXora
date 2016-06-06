/* vcpartns.p
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
        24.04.2008 galina - добавлено поле СЕКТОР ЭКОНОМИКИ
        30.04.2008 galina - перекомпеляция в связи с изменениями формы vcpartners
        02.07.2008 galina - перекомпеляция в связи с изменениями формы vcpartners
        07/10/2010 aigul - перекомпеляция в связи с изменениями формы vcpartners.f
*/

/* vcedpartns.p Валютный контроль
   Редактирование данных инопартнера и верхнее меню

   18.10.2002 nadejda создан
*/

{vc.i}
{mainhead.i}

def shared var s-newpartner as logical.

{sisn.i

&head = "vcpartners"

&headkey = "partner"

&option = "VCPARTNS"

&start = " "

&end = " "

&noedt = false

&nodel = false

&variable = " if vcpartners.cdt <> ? then do: s-noedt = true. s-nodel = true. end. "

&postupdate = " "

&predelete = " find first vccontrs where vccontrs.partner = vcpartners.partner no-lock no-error.
               if avail vccontrs then do: message skip ' Этот партнер указан в контрактах!~n~n Удаление запрещено!' skip(1) view-as alert-box
               button ok title ' ОШИБКА ! '. next. end.
               find first vcdocs where vcdocs.info[4] = vcpartners.partner no-lock no-error.
               if avail vcdocs then do: message skip ' Этот партнер указан в платежных документах!~n~n Удаление запрещено!' skip(1) view-as alert-box
               button ok title ' ОШИБКА ! '. next. end. "

&delete = " delete vcpartners. "

&predisplay = " "

&display = " display vcpartners.partner vcpartners.formasob vcpartner.info[2] vcpartners.name vcpartners.country
      vcpartners.address vcpartners.bankdata vcpartners.rdt vcpartners.rwho
      vcpartners.cdt vcpartners.cwho vcpartners.info[1]
            with frame vcpartners. "

&update = "update
      vcpartners.formasob
      vcpartner.info[2]
      vcpartners.name
      vcpartners.country
      vcpartners.address
      vcpartners.bankdata
      vcpartners.info[1]

            with frame vcpartners."
}

