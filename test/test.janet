(import com.ahungry            :as ahungry    :fresh t)
(import com.ahungry.meta       :as meta       :fresh t)
(import com.ahungry.net        :as net        :fresh t)
(import com.ahungry.net.client :as net.client :fresh t)

(printf "com.ahungry: %s"            (ahungry/exports    :version))
(printf "com.ahungry.meta: %s"       (meta/exports       :version))
(printf "com.ahungry.net: %s"        (net/exports        :version))
(printf "com.ahungry.net.client: %s" (net.client/exports :version))
