/* h-ast.p
 * MODULE
        Основные средства
 * DESCRIPTION
        F2 - выбор карточки AST
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
        06/05/04 sasco Поиск по номеру и по части названия
        14/08/06 sasco Добавил поиск по инвентарному номеру + вместо счета ГК в списке вывел инв.номер
*/

/* h-ast.p
*/

{global.i}
{itemlist.i &start = "def var vans as int.
                      def var vdes as char format 'x(40)'.
                      def var vogr like ast.ast.
                      def var vinv as char.
                      def var v like ast.icost.
		      def var n like ast.icost.
		      vans = 1.
		 message 'Поиск по: 1) номеру карточки; 2) части названия; 3) инв.номеру' update vans.
		 assign vogr = '' vdes = ''.
		 if vans = 1 then message 'Карточка для начала' update vogr.
		 if vans = 2 then message 'Часть названия' update vdes.
		 if vans = 3 then message 'Часть инв.номера' update vinv.
		 if trim (vdes) <> '' then vdes = '*' + trim (vdes) + '*'. else vdes = '*'. 
		 if trim (vinv) <> '' then vinv = '*' + trim (vinv) + '*'. else vinv = '*'. "
       &file = "ast"
       &where = "ast.ast ge vogr and ast.name matches vdes and ast.addr[2] matches vinv "
       &frame = "row 5 centered scroll 1 12 down overlay "
       &flddisp = "ast.ast label 'Nr.Карт.'format 'x(8)' 
                   ast.name label 'Название ' format 'x(21)'
                   ast.dam[1] - ast.cam[1] @ n label 'Перв.стоим' 
                   format 'zzz,zzz,zz9.99-'
                   ast.qty label 'Кол.' format 'zz9-'
                   ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3] @ v 
                   label 'Остат.стоим.' 
                    format 'zzz,zzz,zz9.99-'  
/*                   ast.gl label 'Счет' format 'zzzzz9' */
                   ast.addr[2] label 'Инв.Ном' format 'x(8)' "
       &chkey = "ast"
       &chtype = "string"
       &index  = "ast"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }
