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

    # Don't cache 50x responses
    if (
        beresp.status == 500 ||
        beresp.status == 502 ||
        beresp.status == 503 ||
        beresp.status == 504
    ) {
        return (abandon);
    }

    # === DO NOT CACHE ===
    # Exclude the following paths (e.g. backend admins, user pages or ad URLs that require tracking)
    # In Joomla specifically, you are advised to create specific entry points (URLs) for users to
    # interact with the site (either common user logins or even commenting), e.g. make a menu item
    # to point to a user login page (e.g. /login), including all related functionality such as
    # password reset, email reminder and so on.
    if(
        bereq.url ~ "^/addons" ||
        bereq.url ~ "^/administrator" ||
        bereq.url ~ "^/cart" ||
        bereq.url ~ "^/checkout" ||
        bereq.url ~ "^/component/banners" ||
        bereq.url ~ "^/component/socialconnect" ||
        bereq.url ~ "^/component/users" ||
        bereq.url ~ "^/connect" ||
        bereq.url ~ "^/contact" ||
        bereq.url ~ "^/login" ||
        bereq.url ~ "^/logout" ||
        bereq.url ~ "^/lost-password" ||
        bereq.url ~ "^/my-account" ||
        bereq.url ~ "^/register" ||
        bereq.url ~ "^/signin" ||
        bereq.url ~ "^/signup" ||
        bereq.url ~ "^/wc-api" ||
        bereq.url ~ "^/wp-admin" ||
        bereq.url ~ "^/wp-login.php" ||
        bereq.url ~ "^\?add-to-cart=" ||
        bereq.url ~ "^\?wc-api="
    ) {
        #set beresp.http.Cache-Control = "private, max-age=0, no-cache, no-store";
        #set beresp.http.Expires = "Mon, 01 Jan 2001 00:00:00 GMT";
        #set beresp.http.Pragma = "no-cache";
        set beresp.uncacheable = true;
        return (deliver);
    }

    # Don't cache HTTP authorization/authentication pages and pages with certain headers or cookies
    if (
        bereq.http.Authorization ||
        bereq.http.Authenticate ||
        bereq.http.X-Logged-In == "True" ||
        bereq.http.Cookie ~ "userID" ||
        bereq.http.Cookie ~ "joomla_[a-zA-Z0-9_]+" ||
        bereq.http.Cookie ~ "(wordpress_[a-zA-Z0-9_]+|wp-postpass|comment_author_[a-zA-Z0-9_]+|woocommerce_cart_hash|woocommerce_items_in_cart|wp_woocommerce_session_[a-zA-Z0-9]+)"
    ) {
        #set beresp.http.Cache-Control = "private, max-age=0, no-cache, no-store";
        #set beresp.http.Expires = "Mon, 01 Jan 2001 00:00:00 GMT";
        #set beresp.http.Pragma = "no-cache";
        set beresp.uncacheable = true;
        return (deliver);
    }

    # Don't cache ajax requests
    if(beresp.http.X-Requested-With == "XMLHttpRequest" || bereq.url ~ "nocache") {
        #set beresp.http.Cache-Control = "private, max-age=0, no-cache, no-store";
        #set beresp.http.Expires = "Mon, 01 Jan 2001 00:00:00 GMT";
        #set beresp.http.Pragma = "no-cache";
        set beresp.uncacheable = true;
        return (deliver);
    }

    # Don't cache backend response to posted requests
    if (bereq.method == "POST") {
        set beresp.uncacheable = true;
        return (deliver);
    }

    # Ok, we're cool & ready to cache things
    # so let's clean up some headers and cookies
    # to maximize caching.

    # Check for the custom "X-Logged-In" header to identify if the visitor is a guest,
    # then unset any cookie (including session cookies) provided it's not a POST request.
    if(beresp.http.X-Logged-In == "False" && bereq.method != "POST") {
        unset beresp.http.Set-Cookie;
    }

    # Unset the "pragma" header (suggested)
    unset beresp.http.Pragma;

    # Unset the "vary" header (suggested)
    unset beresp.http.Vary;;

    # If your backend server does not set the right caching headers for static assets,
    # you can set them below (uncomment first and change 604800 - which 1 week - to whatever you
    # want (in seconds)
    #if (bereq.url ~ "\.(ico|jpg|jpeg|gif|png|bmp|webp|tiff|svg|svgz|pdf|mp3|flac|ogg|mid|midi|wav|mp4|webm|mkv|ogv|wmv|eot|otf|woff|ttf|rss|atom|zip|7z|tgz|gz|rar|bz2|tar|exe|doc|docx|xls|xlsx|ppt|pptx|rtf|odt|ods|odp)(\?[a-zA-Z0-9=]+)$") {
    #    set beresp.http.Cache-Control = "public, max-age=604800";
    #}

    if (bereq.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|ogg|ogm|opus|otf|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
        unset beresp.http.set-cookie;
        set beresp.do_stream = true;
    }

    # We have content to cache, but it's got no-cache or other Cache-Control values sent
    # So let's reset it to our main caching time (180s as used in this example configuration)
    # The additional parameters specified (stale-while-revalidate & stale-if-error) are used
    # by modern browsers to better control caching. Set these to twice & four times your main
    # cache time respectively.
    # This final setting will normalize cache-control headers for CMSs like Joomla
    # which set max-age=0 even when the CMS' cache is enabled.
    if (beresp.http.Cache-Control !~ "max-age" || beresp.http.Cache-Control ~ "max-age=0") {
        set beresp.http.Cache-Control = "public, max-age=180, stale-while-revalidate=360, stale-if-error=43200";
    }

    # Optionally set a larger TTL for pages with less than 180s of cache TTL
    #if (beresp.ttl < 180s) {
    #    set beresp.http.Cache-Control = "public, max-age=180, stale-while-revalidate=360, stale-if-error=43200";
    #}

    return (deliver);

}

sub vcl_deliver {
    if (req.http.X-Purger) {
        set resp.http.X-Purger = req.http.X-Purger;
    }

     # Send special headers that indicate the cache status of each web page
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
        set resp.http.X-Cache-Hits = obj.hits;
    } else {
        set resp.http.X-Cache = "MISS";
    }

    return (deliver);
}

sub vcl_purge {
    set req.method = "GET";
    set req.http.X-Purger = "Purged";
    return (restart);
}