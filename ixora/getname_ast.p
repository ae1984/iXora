/* getprefix_ast.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Возвращает префикс филиальского клиента
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
 * AUTHOR
        07/09/2011 madiyar
 * BASES
        BANK AST
 * CHANGES
*/

def input parameter v-rnn as char no-undo.
def input parameter v-bin as logi no-undo.
def output parameter v-name as char no-undo.

if v-bin then do:
    find first ast.cif where ast.cif.bin = v-rnn no-lock no-error.
    if avail ast.cif then v-name = trim(trim(ast.cif.prefix) + " " + trim(ast.cif.name)).
end.
else do:
    find first ast.cif where ast.cif.jss = v-rnn no-lock no-error.
    if avail ast.cif then v-name = trim(trim(ast.cif.prefix) + " " + trim(ast.cif.name)).
end.



