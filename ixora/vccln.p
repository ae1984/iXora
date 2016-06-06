/* vccln.p
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

/* vccln.p 
 * Модуль
     Валютный контроль 
 * Назначение
     Просмотр данных клиента, переход к контрактам
 * Применение
     Отдел валютного контроля и менеджеры СПФ
 * Вызов
     главное меню
 * Меню
     15.1

 * Автор
     nadejda
 * Дата создания:
     18.10.2002
 * Изменения                       
      25.04.2004 dpuchkov перекомпиляция
*/

{vc.i}

{mainhead.i VCCONTRS}

{sixn.i 
 &head = cif
 &headkey = cif
 &option = CIF
 &no-add = " 
    message skip ' Нельзя создавать нового клиента в этом пункте меню !' skip(1) 
       view-as alert-box button ok title ''.
    next. "
 &numsys = auto
 &numprg = xxx
 &keytype = string
 &nmbrcode = CIF
 &subprg = vcclns
}




