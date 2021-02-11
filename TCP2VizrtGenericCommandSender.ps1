# A script to send any commands to Vizrt's Viz graphics rendering engine
# Supported Viz commands can be found at https://documentation.vizrt.com/viz-engine-guide-3.14.pdf
# To run this script in Windows, %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -file TCP2VizrtGenericCommandSender.ps1
# By Jun Ye - 08 Feb 2021
# Email: jellun@hotmail.com

[int] $port = 6100
$engine = "127.0.0.1" # Hostname or IP address
#$engine = "localhost" # Hostname or IP address: [127.0.0.1] [localhost] [MachineName] [MachineName.DomainName]

$saddrf = [System.Net.Sockets.AddressFamily]::InterNetwork
$stype = [System.Net.Sockets.SocketType]::Stream
$ptype = [System.Net.Sockets.ProtocolType]::TCP
$script:sock = New-Object System.Net.Sockets.Socket $saddrf, $stype, $ptype
$script:sock.TTL = 26

$Enc = [System.Text.Encoding]::ASCII

if ($engine.Split('.').Length -ge 4) # An IP address
{
	$script:IPaddr = [system.net.IPAddress]::Parse($engine)
	$script:endPoint = New-Object System.Net.IPEndPoint $script:IPaddr, $port
	try
	{
		$script:sock.Connect($script:endPoint)
		if ($script:sock.Connected)
		{
			$script:endPoint
		}
	}
	catch
	{
		$Error
		exit
	}
}
else # A Hostname
{
	$script:hostEntry = [System.Net.Dns]::GetHostEntry($engine)
	foreach ($aHostAddr in $script:hostEntry.AddressList)
    {
        $script:endPoint = New-Object System.Net.IPEndPoint $aHostAddr, $port
        if ($script:endPoint.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork)
        {
			try
			{
				$script:sock.Connect($script:endPoint)
				if ($script:sock.Connected)
				{
					$script:endPoint
					break
				}
			}
			catch
			{
				$Error
				exit
			}
        }
    }
}

if (!($script:sock.Connected))
{
    "Cannot connect to the engine! Exit!"
    exit
}

try
{
    $Commands = "0 RENDERER SET_OBJECT SCENE*Default\TestFreeArt01`0"
    $BufferSend = $Enc.GetBytes($Commands)
    "Sending command: {$Commands} to Viz Engine"
    $SentBytes = $script:sock.Send($BufferSend)
    "{0} characters sent to: {1} " -f $SentBytes,$engine
    [byte[]]$BufferRevd = New-Object Byte[] 1024
    $ReceivedBytes = $script:sock.Receive($BufferRevd)
    $ReceivedMsg = $Enc.GetString($BufferRevd, 0, $ReceivedBytes)
    "Received message: {$ReceivedMsg} from Viz Engine"
}
catch
{
    $Error
}

try
{
    $script:sock.Close()
    $script:sock.Dispose()
}
catch
{
    $Error
}

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
