/* pmenu.p
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
        06/02/02 sasco - отправка ЛОГов по почте на aдрес pragmalog@mail.texakabank.kz 
        06/01/04 koval Убрал отправку на почту, ввел логирование savelog, убрал putlog
	29.10.2008 id00024 - изменил приветствие с Добрый День! на Ќош келдіѕіздер! 
*/

def var v-dir    as char.
def var ipaddr   as char format 'x(15)'.
def var cHost    as char format 'x(15)'.
def var cSoob    as char format 'x(60)'.
def var l        as log  init no.
def var username as char format 'x(15)'.
def var pswd     as char init 'XXXX' label 'Parole' view-as fill-in.
def var i        as int  init 0.
def var oklog    as log.
def frame Login 

    '' skip(1)
    ' Введите Ваше имя :' username format 'x(15)' space(1) skip 
    ' Пароль           :' pswd     format 'X(15)' 
    '' skip(1)
    with 1 down no-labels row 10 centered 
    title '[ Ќош келдіѕіздер! ]'. /* 29.10.2008 id00024 */

    oklog = FALSE.

    v-dir = pdbname( 'bank' ).
    file-info:file-name = v-dir + '.soob'.
    if file-info:file-type <> ? then do:
    
       input from value( v-dir + '.soob' ) no-echo.
       repeat:
          import delimiter '@' cSoob no-error.
       end.
       input close.
    
       if cSoob <> '' then do:
          do while not l:
             run yn( 'Внимание!', '', cSoob, '', output l ).
          end.
       end.
    end.
                              
    input through whoami.
    repeat:
       import username.
    end.
    input close.
    
    input through askhost.
    repeat:
       import cHost.
    end.
    input close.
                       
    input through value( 'resolveip -s ' + cHost ).
    repeat:
       import ipaddr.
    end.
    input close.
                                
    assign pswd:blank = true. i = 0.
    do while userid( 'bank' ) = '':
       pswd = ''.
       i = i + 1.
       if i > 3 then do:
          /*run putlog( 'Неудача...' ).   */
          run savelog('login',' ' + ipaddr + ' ' + cHost + ' ' + username + ' Logon Failed').
/*
unix silent echo `hostname`#`date`#`askhost`#`whoami`#FAILED |  mail -s "P"
pragmalog@mail.texakabank.kz.
*/
          quit.
       end.
       repeat on endkey undo, retry: 
          update 
          username help 'Для входа в систему введите Ваше имя...'          
          pswd     help 'Для входа в систему введите Ваш пароль...' 
          with frame Login. 
          if lastkey <> keycode('F4') then leave.
       end. 
       if not setuserid( username, pswd, 'bank' ) then do:
       /* run putlog( 'Ошибка...' ).*/
          run savelog('login',' ' + ipaddr + ' ' + cHost + ' ' + username + ' Logon Error').
/*
unix silent echo `hostname`#`date`#`askhost`#`whoami`#Error |  mail -s "P"
pragmalog@mail.texakabank.kz.
*/
          run tb( '', '', 'Вы ошиблись! Повторите...', '' ).
       end.
       hide frame Login no-pause.
    end.

    /*run putlog( 'Оk...' ).*/
    
    if not oklog then do:
          run savelog('login',' ' + ipaddr + ' ' + cHost + ' ' + username + ' Logon Ok').
          /*       unix silent value ("echo `hostname`#`date`#`askhost`#`whoami`#OK |  mail -s ""P"" pragmalog@mail.texakabank.kz").*/
       oklog = TRUE.
    end.
                        
    pause 0. 
    run amenu.

return.
/**
procedure putlog:
def input parameter s as char.

   output to value ( v-dir + '.logins' ) append no-echo.
   put string( today ) + ' ' + string( time, 'HH:MM:SS' ) + ' ' format 'x(18)'
   cHost
   ipaddr
   username
   s format 'x(16)'
   skip.
   output close.   
                        
end.
*/
/***/

                                              