(import com.ahungry :as ahungry)
(import com.ahungry.net :as net)
(import com.ahungry.net.client :as client)

(printf "com.ahungry: %s"            (ahungry/exports :version))
(printf "com.ahungry.net: %s"        (net/exports :version))
(printf "com.ahungry.net.client: %s" (client/exports :version))
