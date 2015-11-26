<?php

// TODO: retrieve stream list via lua web script with flussonic.streams() function

include_once("conf.php");


if($_SERVER["REQUEST_URI"] == "/") {
    $streams = get_streams();
    
    echo "<ul>";
    foreach($streams as $stream) {
        $qs = http_build_query(array("name" => $stream[1]));
        echo "<li><a href=\"$stream[0]?$qs\">$stream[1]</a>";
    }
    echo "</ul>";

} else {
    $stream = substr($_SERVER["SCRIPT_NAME"], 1);
    $name = $_REQUEST["name"];
    $opts = array('http' => array('method'  => 'GET'));
    $context = stream_context_create($opts);
    global $FLUSSONIC_URL, $TIMESPAN;
    $ip = $_SERVER["REMOTE_ADDR"];

    $authetnicator_salt = bin2hex(openssl_random_pseudo_bytes(16));
    $authetnicator = $authetnicator_salt . "." . hash("sha256", $authetnicator_salt . $TOKEN_GENERATOR_PASSWORD);
    $url = "$FLUSSONIC_URL/auth_helpers/mktoken?stream=$stream&ip=$ip&timespan=$TIMESPAN&authenticator=$authetnicator";
    $token = file_get_contents($url, false, $context);
    if (!$token) {
        exit(500);
    }

    $embed = "$FLUSSONIC_URL/$stream/embed.html?dvr=false&token=$token";

    echo $name;
    echo "<br><br>";
    echo "<iframe frameborder=\"0\" style=\"width:853px; height:480px;\" src=\"$embed\"> </iframe>";
}


function get_streams()
{
    global $FLUSSONIC_URL, $FLUSSONIC_USER, $FLUSSONIC_PASS;
    $url = "$FLUSSONIC_URL/flussonic/api/get_config";
    $config = get_json($url, $FLUSSONIC_USER, $FLUSSONIC_PASS);
    $streams = array();
    foreach($config["config"] as $item) {
        if($item["entry"] != "stream")
            continue;
        $stream = $item["value"]["name"];
        $name = $stream;
        if(array_key_exists("meta", $item["value"]["options"])) {
            foreach($item["value"]["options"]["meta"] as $meta) {
                if($meta[0] == "name")
                    $name = $meta[1];
            }
        }
        $s = array($stream, $name);
        array_push($streams, array($stream, $name));
    }
    return $streams;
}


function get_json($url, $user, $pass)
{
    $opts = array('http' =>
                  array('method'  => 'GET',
                        "header" => "Authorization: Basic " . base64_encode("$user:$pass") . "\r\n"));
    $context = stream_context_create($opts);
    $json = file_get_contents($url, false, $context);
    return json_decode($json, true);
}


?>
