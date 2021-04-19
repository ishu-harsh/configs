vcl 4.0;

backend default {
.host = "localhost";
.port = "8080";
}

backend mail250.com {
.host = "localhost";
.port = "8080";
}


backend mimepost.com {
.host = "localhost";
.port = "8080";
}

acl purger {
"localhost";
"65.2.82.131";
}


sub vcl_recv {

     if (req.http.host == "mail250.com" && req.http.host == "www.mail250.com"){

        set req.backend_hint = mail250.com;

            if (client.ip != "127.0.0.1" && req.http.host ~ "mail250.com") {
                set req.http.x-redir = "https://mail250.com" + req.url;
                return(synth(850, ""));
            }

            if (req.method == "PURGE") {
                if (!client.ip ~ purger) {
                return(synth(405, "This IP is not allowed to send PURGE requests."));
            }
            return (purge);
            }

                        
            if (req.restarts == 0) {
                if (req.http.X-Forwarded-For) {
                set req.http.X-Forwarded-For = client.ip;
                }
            }

            if (req.http.Authorization || req.method == "POST") {
                return (pass);
            }

            if (req.url ~ "/feed") {
                return (pass);
            }

            if (req.url ~ "users") {
                return (pass);
            }


            if (req.url ~ "wp-admin|wp-login") {
                return (pass);
            }
            set req.http.cookie = regsuball(req.http.cookie, "wp-settings-\d+=[^;]+(; )?", "");
            set req.http.cookie = regsuball(req.http.cookie, "wp-settings-time-\d+=[^;]+(; )?", "");

            if (req.http.cookie == "") {
            unset req.http.cookie;
            }

        return (lookup);
     }


     if (req.http.host == "mimepost.com" && req.http.host == "www.mimepost.com"){

        set req.backend_hint = mimepost.com;
    
        
        
        return (lookup)
     }

 

}

sub vcl_synth {
 if (resp.status == 850) {
     set resp.http.Location = req.http.x-redir;
     set resp.status = 302;
     return (deliver);
 }
}



sub vcl_backend_response {
    set beresp.ttl = 24h;
    set beresp.grace = 1h;

    if (bereq.url !~ "wp-admin|wp-login|product|cart|checkout|my-account|/?remove_item=") {
    unset beresp.http.set-cookie;
    }
    if (beresp.status >= 400) {
    return (pass);
    }

}

sub vcl_deliver {
    if (req.http.X-Purger) {
        set resp.http.X-Purger = req.http.X-Purger;
    }
}

sub vcl_purge {
    set req.method = "GET";
    set req.http.X-Purger = "Purged";
    return (restart);
}