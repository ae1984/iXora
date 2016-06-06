/* pkdoglst.f
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



form
  pkdocs.name format "x(40)"
    validate (pkdocs.name <> "", " Введите название документа !")
  pkdocs.credtype format "x(10)" label "ВИДЫ КРЕД"
    validate (pkdocs.credtype = "0" or 
              can-find(bookcod where bookcod.bookcod = "credtype" and bookcod.code = pkdocs.credtype no-lock), 
              " Неверный список видов кредитов (введите 0 или список через запятую)!")
  pkdocs.proc format "x(17)"
    validate (pkdocs.proc <> "", " Введите наименование процедуры !")
  pkdocs.separat label "РАЗЛИЧ?"
  with centered 14 down title " ДОКУМЕНТЫ ПОТРЕБИТЕЛЬСКОГО КРЕДИТОВАНИЯ " overlay row 3 frame f-docs.