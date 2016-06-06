/* astatb.p
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

/* 11.04.2003 Sasco - запись перемещения по департаментам в историю */

{mainhead.i}

/*define new shared var g-lang as character format "x(8)".
g-lang = "RS".*/

def variable v-at as char format "x(20)". 
def variable v-vt as char format "x(20)". 

/* место расположения - из справочника Профит-центров */
/* find astotv where astotv.kotv=v-attn and astotv.priz="V" no-lock no-error.
 if avail astotv then  v-attnn=astotv.otvp.
 find codfr where codfr.codfr = 'sproftcn' and codfr.code = ast.attn no-lock no-error.
 if avail codfr then v-attnn = trim(codfr.name[1]).
*/

def var o-attn like ast.attn.

{jabra.i
&head = "ast"
&headkey = "ast"
&index = "ast"
&where = "true"
&addcon = "false"
&deletecon = "false"
&start = " "
&formname = "astr"
&framename = "astr"
&postadd = " "
&prechoose = "find astotv where astotv.kotv = ast.addr[1] and astotv.priz = 'A' no-lock no-error.
              if avail astotv then v-at = astotv.otvp. 
                 else v-at = 'ответ.лица нет     !!!'.
              find codfr where codfr.codfr = 'sproftcn' and codfr.code = ast.attn no-lock no-error.
              if avail codfr then v-vt = trim(codfr.name[1]).
                 else v-vt = 'места распол. нет!!!'.               
              message v-at + ' /  ' + v-vt .
 message color normal
'       <Enter>-РЕДАКТИРОВАТЬ  <F4>-ВЫХОД'.
              "
&display   = "ast.ast ast.name ast.gl ast.fag ast.noy ast.ldd ast.addr[1] ast.attn "
&highlight = "ast.ast ast.name ast.fag ast.gl ast.noy ast.ldd ast.addr[1] ast.attn "
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do transaction 
          on endkey undo, leave:
            do on endkey undo, leave:
             hide message no-pause.
              message color normal
'               <Enter>-ВВОД <F1>-СОХРАНЕНИЕ <F4>-ОТКАЗ'.
               o-attn = ast.attn.
               update ast.addr[1] ast.attn 
                     validate(can-find(codfr where codfr.codfr = 'sproftcn' and 
                     codfr.code = ast.attn and codfr.code matches '...'),
                     'Кода ' + ast.attn + ' нет в словаре')
                 with frame astr.

              ast.who = g-ofc.
              ast.whn = g-today.
             end.
               displ  ast.addr[1] ast.attn with frame astr.
            if ast.attn <> o-attn then do:
            create hist.
            assign hist.date = g-today
                   hist.who = g-ofc
                   hist.ctime = time
                   hist.pkey = 'AST'
                   hist.skey = ast.ast
                   hist.op = 'MOVEDEP'
                   hist.chval[1] = ast.attn /* новый департ. */
                   hist.chval[2] = o-attn   /* старый департ. */
                   hist.chval[3] = ast.addr[2] /* старый инв.н. */
                   hist.chval[4] = ast.addr[2]. /* старый инв.н. */
            end.
           end."
&end = "hide message no-pause."
}

