#!/usr/bin/env bash

generate_confusables() {
    local text="$1"
    local limit="${2:-10}"

    [[ -n "$text" ]] || return 0

    if [[ ! "$limit" =~ ^[1-9][0-9]*$ ]]; then
        return 1
    fi

    local -a variants=()
    local -a options=()

    local i=0
    local char
    local replacement
    local variant

    while IFS= read -r -d '' char; do

        case "$char" in

            a)
                options=(
                    "à" "á" "â" "ã" "ä" "å"
                    "ā" "ă" "ą" "ǎ" "ǟ" "ǡ"
                    "а" "α"
                )
                ;;

            A)
                options=(
                    "À" "Á" "Â" "Ã" "Ä" "Å"
                    "Ā" "Ă" "Ą" "Ǎ" "Ǟ" "Ǡ"
                    "А" "Α"
                )
                ;;

            b)
                options=(
                    "ḅ" "ḇ" "ƀ" "Ь" "ь"
                    "в" "β"
                )
                ;;

            B)
                options=(
                    "Ḅ" "Ḇ" "Ɓ" "Ь"
                    "В" "Β"
                )
                ;;

            c)
                options=(
                    "ç" "ć" "ĉ" "ċ" "č"
                    "ḉ" "ƈ" "с" "ϲ"
                )
                ;;

            C)
                options=(
                    "Ç" "Ć" "Ĉ" "Ċ" "Č"
                    "Ḉ" "Ƈ" "С" "Ϲ"
                )
                ;;

            d)
                options=(
                    "ď" "đ" "ḋ" "ḍ"
                    "ḏ" "ḓ" "ԁ" "ԃ"
                )
                ;;

            D)
                options=(
                    "Ď" "Đ" "Ḋ" "Ḍ"
                    "Ḏ" "Ḓ" "Ԁ" "Ԃ"
                )
                ;;

            e)
                options=(
                    "è" "é" "ê" "ë"
                    "ē" "ĕ" "ė" "ę" "ě"
                    "ẻ" "ẽ" "ẹ"
                    "е" "ε"
                )
                ;;

            E)
                options=(
                    "È" "É" "Ê" "Ë"
                    "Ē" "Ĕ" "Ė" "Ę" "Ě"
                    "Ẻ" "Ẽ" "Ẹ"
                    "Е" "Ε"
                )
                ;;

            f)
                options=(
                    "ḟ" "ƒ"
                )
                ;;

            F)
                options=(
                    "Ḟ" "Ƒ"
                )
                ;;

            g)
                options=(
                    "ĝ" "ğ" "ġ" "ģ"
                    "ǵ" "ḡ" "ɡ"
                    "ԍ" "ɢ" "γ"
                )
                ;;

            G)
                options=(
                    "Ĝ" "Ğ" "Ġ" "Ģ"
                    "Ǵ" "Ḡ" "Ɠ"
                    "Ԍ" "Γ"
                )
                ;;

            h)
                options=(
                    "ĥ" "ħ" "ḧ" "ḩ"
                    "ḫ" "ḥ" "һ" "н"
                )
                ;;

            H)
                options=(
                    "Ĥ" "Ħ" "Ḧ" "Ḩ"
                    "Ḫ" "Ḥ" "Һ" "Н"
                )
                ;;

            i)
                options=(
                    "ì" "í" "î" "ï"
                    "ĩ" "ī" "ĭ" "į"
                    "ı" "ǐ" "ỉ" "ị"
                    "і" "ι"
                )
                ;;

            I)
                options=(
                    "Ì" "Í" "Î" "Ï"
                    "Ĩ" "Ī" "Ĭ" "Į"
                    "Ǐ" "Ỉ" "Ị"
                    "І" "Ι"
                )
                ;;

            j)
                options=(
                    "ĵ" "ǰ" "ј"
                )
                ;;

            J)
                options=(
                    "Ĵ" "Ј"
                )
                ;;

            k)
                options=(
                    "ķ" "ḱ" "ḳ"
                    "ḵ" "κ" "к"
                )
                ;;

            K)
                options=(
                    "Ķ" "Ḱ" "Ḳ"
                    "Ḵ" "Κ" "К"
                )
                ;;

            l)
                options=(
                    "ĺ" "ļ" "ľ" "ł"
                    "ḷ" "ḹ" "ḽ" "ƚ"
                    "ⅼ" "ӏ"
                )
                ;;

            L)
                options=(
                    "Ĺ" "Ļ" "Ľ" "Ł"
                    "Ḷ" "Ḹ" "Ḽ" "Ƚ"
                    "Ⅼ"
                )
                ;;

            m)
                options=(
                    "ḿ" "ṁ" "ṃ"
                    "м" "ᴍ"
                )
                ;;

            M)
                options=(
                    "Ḿ" "Ṁ" "Ṃ"
                    "М" "Μ"
                )
                ;;

            n)
                options=(
                    "ñ" "ń" "ņ" "ň"
                    "ŋ" "ṅ" "ṇ" "ṉ"
                    "ṋ" "ո" "п"
                )
                ;;

            N)
                options=(
                    "Ñ" "Ń" "Ņ" "Ň"
                    "Ŋ" "Ṅ" "Ṇ" "Ṉ"
                    "Ṋ" "Ν" "П"
                )
                ;;

            o)
                options=(
                    "ò" "ó" "ô" "õ" "ö"
                    "ø" "ō" "ŏ" "ő"
                    "ǒ" "ǫ" "ǭ" "ȯ"
                    "ọ" "о" "ο"
                )
                ;;

            O)
                options=(
                    "Ò" "Ó" "Ô" "Õ" "Ö"
                    "Ø" "Ō" "Ŏ" "Ő"
                    "Ǒ" "Ǫ" "Ǭ" "Ȯ"
                    "Ọ" "О" "Ο"
                )
                ;;

            p)
                options=(
                    "ṕ" "ṗ"
                    "р" "ρ"
                )
                ;;

            P)
                options=(
                    "Ṕ" "Ṗ"
                    "Р" "Ρ"
                )
                ;;

            q)
                options=(
                    "ɋ"
                )
                ;;

            Q)
                options=(
                    "Ɋ"
                )
                ;;

            r)
                options=(
                    "ŕ" "ŗ" "ř"
                    "ṙ" "ṛ" "ṝ" "ṟ"
                    "г"
                )
                ;;

            R)
                options=(
                    "Ŕ" "Ŗ" "Ř"
                    "Ṙ" "Ṛ" "Ṝ" "Ṟ"
                    "Г"
                )
                ;;

            s)
                options=(
                    "ś" "ŝ" "ş" "š" "ș"
                    "ṡ" "ṣ" "ṥ" "ṧ" "ṩ"
                    "ѕ" "σ" "ς"
                )
                ;;

            S)
                options=(
                    "Ś" "Ŝ" "Ş" "Š" "Ș"
                    "Ṡ" "Ṣ" "Ṥ" "Ṧ" "Ṩ"
                    "Ѕ" "Σ"
                )
                ;;

            t)
                options=(
                    "ţ" "ť" "ț" "ŧ"
                    "ṫ" "ṭ" "ṯ" "ṱ"
                    "т" "τ"
                )
                ;;

            T)
                options=(
                    "Ţ" "Ť" "Ț" "Ŧ"
                    "Ṫ" "Ṭ" "Ṯ" "Ṱ"
                    "Т" "Τ"
                )
                ;;

            u)
                options=(
                    "ù" "ú" "û" "ü"
                    "ũ" "ū" "ŭ" "ů"
                    "ű" "ų" "ǔ"
                    "ǖ" "ǘ" "ǚ" "ǜ"
                    "ụ" "ủ" "υ"
                )
                ;;

            U)
                options=(
                    "Ù" "Ú" "Û" "Ü"
                    "Ũ" "Ū" "Ŭ" "Ů"
                    "Ű" "Ų" "Ǔ"
                    "Ǖ" "Ǘ" "Ǚ" "Ǜ"
                    "Ụ" "Ủ" "Υ"
                )
                ;;

            v)
                options=(
                    "ṽ" "ṿ"
                    "ν" "ѵ"
                )
                ;;

            V)
                options=(
                    "Ṽ" "Ṿ"
                    "Ν" "Ѵ"
                )
                ;;

            w)
                options=(
                    "ŵ" "ẁ" "ẃ"
                    "ẅ" "ẇ" "ẉ"
                    "ԝ"
                )
                ;;

            W)
                options=(
                    "Ŵ" "Ẁ" "Ẃ"
                    "Ẅ" "Ẇ" "Ẉ"
                    "Ԝ"
                )
                ;;

            x)
                options=(
                    "ẋ" "ẍ"
                    "х" "χ"
                )
                ;;

            X)
                options=(
                    "Ẋ" "Ẍ"
                    "Х" "Χ"
                )
                ;;

            y)
                options=(
                    "ý" "ÿ" "ŷ" "ȳ"
                    "ẏ" "ỳ" "ỵ"
                    "у" "γ"
                )
                ;;

            Y)
                options=(
                    "Ý" "Ÿ" "Ŷ" "Ȳ"
                    "Ẏ" "Ỳ" "Ỵ"
                    "У" "Γ"
                )
                ;;

            z)
                options=(
                    "ź" "ż" "ž"
                    "ẑ" "ẓ" "ẕ"
                    "ѕ" "ζ"
                )
                ;;

            Z)
                options=(
                    "Ź" "Ż" "Ž"
                    "Ẑ" "Ẓ" "Ẕ"
                    "Ѕ" "Ζ"
                )
                ;;

            *)
                options=()
                ;;
        esac

        for replacement in "${options[@]}"; do

            variant="${text:0:i}${replacement}${text:i+1}"

            if [[ "$variant" != "$text" ]]; then
                variants+=("$variant")

                if (( ${#variants[@]} >= limit )); then
                    printf '%s\n' "${variants[@]}"
                    return 0
                fi
            fi

        done

        ((i++))

    done < <(
        printf '%s' "$text" |
        grep -oP '.' |
        while IFS= read -r char; do
            printf '%s\0' "$char"
        done
    )

    printf '%s\n' "${variants[@]}"
}
