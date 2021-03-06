#INCLUDE "TOTVS.CH"

User Function MAILPOP()
Local cProtocolo    := 'POP3'
Local oServer       := Nil
Local nMessages     := 00
Local cAviso        := ''
Local xRet          := 00

Local cServer       := 'outlook.office365.com'
Local cConta        := 'nfe@midoriautoleather.com.br'
Local cPass         := 'Bam67871'
Local nPortaNF      := 995
Local lSSL          := .T.

oServer := tMailManager():New()



oServer:SetUseSSL(lSSL)
//oServer:SetUseTLS(lSSL)
xRet := oServer:Init(cServer, "", cConta, cPass, nPortaNF, 0)
oServer:SetPOPTimeout(120)  

If xRet <> 0
	Alert("Servidor n�o p�de ser iniciado: " + oServer:GetErrorString(xRet))
	Return( Nil )
endif

xRet := oServer:POPConnect()
If xRet <> 0
	Alert("N�o foi poss�vel conectar ao servidor "+cProtocolo+": " + oServer:GetErrorString(xRet))
	Return( Nil )
EndIf

oServer:GetNumMsgs(@nMessages) 
If nMessages > 0 .And. xRet == 0
    cAviso 	:= "A conta "+cConta+" contem "+StrZero(nMessages,8)+" mensagem(s)" 
    Aviso("Aten��o",cAviso,{"Cancelar"})
Endif

Return( Nil )