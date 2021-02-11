# A script to send any commands to Vizrt's Viz graphics rendering engine
# Supported Viz commands can be found at https://documentation.vizrt.com/viz-engine-guide-3.14.pdf
# To run this script in Windows, %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -file UDP2VizrtGenericCommandSender.ps1
# By Jun Ye - 08 Feb 2021
# Email: jellun@hotmail.com

[int] $port = 6400 #Enable UDP on Viz Config and set to port 6400
$IP = "127.0.0.1"
$address = [system.net.IPAddress]::Parse($IP)
$endPoint = New-Object System.Net.IPEndPoint $address, $port

$saddrf = [System.Net.Sockets.AddressFamily]::InterNetwork
$stype = [System.Net.Sockets.SocketType]::Dgram
$ptype = [System.Net.Sockets.ProtocolType]::UDP
$sock = New-Object System.Net.Sockets.Socket $saddrf, $stype, $ptype
$sock.TTL = 26

$sock.Connect($endPoint)
$Enc = [System.Text.Encoding]::ASCII

$Commands = "0 RENDERER SET_OBJECT SCENE*Default\TestFreeArt01`0"
$BufferSend = $Enc.GetBytes($Commands)
"Sending command: {$Commands} to Viz Engine"
$SentBytes = $sock.Send($BufferSend)
"{0} characters sent to: {1} " -f $SentBytes,$IP
#[byte[]]$BufferRevd = New-Object Byte[] 1024
#$ReceivedBytes = $Sock.Receive($BufferRevd)
#$ReceivedMsg = $Enc.GetString($BufferRevd, 0, $ReceivedBytes)
#"Received message: {$ReceivedMsg} from Viz Engine"

$Commands = "0 RENDERER*STAGE START`0"
$BufferSend = $Enc.GetBytes($Commands)
"Sending command: {$Commands} to Viz Engine"
$SentBytes = $sock.Send($BufferSend)
"{0} characters sent to: {1} " -f $SentBytes,$IP

$Sock.Close()
$Sock.Dispose()

# Command examples
#0 RENDERER SET_OBJECT SCENE*Default\TestFreeArt01
#0 RENDERER*STAGE START
#0 RENDERER*STAGE CONTINUE
#0 RENDERER SET_OBJECT
#0 send 0 RENDERER GET_OBJECT_LOCATION_PATH

#0 RENDERER*FRONT_LAYER SET_OBJECT
#0 RENDERER*MAIN_LAYER SET_OBJECT
#0 RENDERER*BACK_LAYER SET_OBJECT
#0 SCENE CLEANUP
#0 GEOM CLEANUP
#0 IMAGE CLEANUP
#0 FONT CLEANUP
#0 MATERIAL CLEANUP
#0 MAPS CACHE CLEANUP
