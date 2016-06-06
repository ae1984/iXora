/* set-password.p
 * MODULE
        Управление офицерами Прагмы
 * DESCRIPTION
        Установка пароля пользователя принятого по умолчанию (по умолчанию пароль пользователя равен логину пользователя)
 * RUN
        
 * CALLER
        x-ofc.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        27.07.2006 u00121
 * CHANGES
        31.08.2006 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
	03.12.2008 id00024 - закоментил -H и -S до лучших времен, и добавил выбор МКО или БАНКа
*/
define shared var vofc like bank.ofc.ofc.

message "Установить пользователю " vofc " пароль по умолчанию?" view-as alert-box BUTTONS OK-CANCEL UPDATE setpas as log.
if setpas then
do:
	message "Сбросить пароль на всех филиалах?" view-as alert-box BUTTONS OK-CANCEL UPDATE setbr as log.
	if setbr then
	do: /*если сказали Ок, то сбрасываем пароль везде*/
		{r-branch.i &proc = "setpassbr(vofc)"}
	end.
	else
	do:     /* 03.12.2008 id00024 - добавил выбор МКО или БАНКа */
			run sel ("It's time to choose mr. Freeman :", " 1. BAHK | 2. MKO  ").
			case return-value:
			when "1" then v-path = '/data/b'.
			when "2" then v-path = '/data/'.
			end case.

		/*иначе, покажем список всех филиалов, пользователь должен выбрать, в каких из них нужно сбросить пароль и начать F1*/
		def temp-table t-branch no-undo /*таблица для списка филиалов*/
			field path as char
			field host like comm.txb.host
			field serv like comm.txb.service
			field login as char
			field password as char
			field name as char format "x(30)"
			field txb as int
			field sel as log format "<*>/"
			index idx-txb is unique primary txb.
		
		for each comm.txb where comm.txb.consolid = true no-lock: /*заполняем таблицу списка филиалов*/
			create t-branch. 
			assign
				t-branch.path = comm.txb.path
				t-branch.host = comm.txb.host
				t-branch.serv = comm.txb.service
				t-branch.login = comm.txb.login
				t-branch.password = comm.txb.password
				t-branch.name = comm.txb.name
				t-branch.txb = comm.txb.txb.
		end.

	        def query q-branch for t-branch.

		def browse b-branch 
			query q-branch no-lock
				display t-branch.name t-branch.sel with 10 down width 50 title "Список филиалов" no-labels.

		def frame f-branch
			b-branch help "" with centered no-label  row 2.

                on return of b-branch in frame f-branch /*нажатие клавиши ENTER приводит к выделению или отмене выделения филиала*/
		do:
			if avail t-branch then
			do:
				if t-branch.sel then
					t-branch.sel = false.
				else
					t-branch.sel = true.
				open query q-branch for each t-branch.
			end.
			
	        end.

                open query q-branch for each t-branch.

                view frame f-branch.

                enable b-branch with frame f-branch.

                apply "VALUE-CHANGED" to BROWSE b-branch.
                WAIT-FOR "GO" OF FRAME f-branch.

		for each t-branch where t-branch.sel no-lock. /*пробигаемся по составленному пользователем списку, и сбрасываем пароль*/
                    	if connected ("txb") then disconnect "txb".
/*                         	connect value(" -db " + t-branch.path + " -H " + t-branch.host + " -S " + t-branch.serv  + " -ld txb -U " + t-branch.login + " -P " + t-branch.password).  */
                               	connect value(" -db " + replace(t-branch.path,'/data/',v-path) + " -ld txb -U " + t-branch.login + " -P " + t-branch.password). /* id00024 03.12.2008 */
                        run setpassbr(vofc).
                        if connected ("txb") then disconnect "txb".
		end.
	end.
end.