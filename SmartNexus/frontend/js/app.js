/* =====================================================
   Página de demandas
   - mostra as perguntas certas conforme o tipo de projeto
   - aplica os limites de cada plano
   - atualiza o resumo do pedido ao vivo
   - valida o formulário
   ===================================================== */
(function () {
    const form = document.getElementById("form-demanda");
    const sucesso = document.getElementById("sucesso");
    const resumo = document.getElementById("resumo-lista");
    const contador = document.getElementById("contador");

    const $ = (seletor, raiz = document) => raiz.querySelector(seletor);
    const $$ = (seletor, raiz = document) => Array.from(raiz.querySelectorAll(seletor));

    const TIPOS = {
        site: "Site",
        marketing: "Anúncios e redes sociais",
        ambos: "Site + anúncios",
    };

    const NOMES = {
        instagram: "Instagram",
        youtube: "YouTube",
        tiktok: "TikTok",
        google: "Google Pesquisa",
    };

    const movimentoReduzido = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    /* ---------- leitura do estado ---------- */
    const planoAtual = () => $('input[name="plano"]:checked', form);
    const tipoAtual = () => form.elements["tipo"].value;
    const marcados = (nome) => $$(`input[name="${nome}"]:checked`, form);

    function textoDoSelect(nome) {
        const campo = form.elements[nome];
        return campo.value ? campo.selectedOptions[0].textContent : "";
    }

    /* ---------- blocos que aparecem conforme o tipo ---------- */
    function mostrarBlocos() {
        const tipo = tipoAtual();
        $$("[data-bloco]", form).forEach((bloco) => {
            const visivel = tipo === "ambos" || tipo === bloco.dataset.bloco;
            if (visivel && bloco.hidden) {
                bloco.hidden = false;
                bloco.classList.add("aparece");
            }
            if (!visivel) {
                bloco.hidden = true;
                bloco.classList.remove("aparece");
            }
        });
    }

    /* ---------- limites do plano ---------- */
    function limitar(nome, maximo) {
        const itens = $$(`input[name="${nome}"]`, form);
        const total = itens.filter((i) => i.checked).length;
        itens.forEach((i) => {
            i.disabled = maximo > 0 && !i.checked && total >= maximo;
        });
    }

    function atualizarLimitesEDicas() {
        const p = planoAtual();
        const maxPlat = Number(p.dataset.maxPlat) || 0;
        const maxAdd = Number(p.dataset.maxAdd) || 0;

        limitar("plataformas", maxPlat);
        limitar("adicionais", maxAdd);

        const nPlat = marcados("plataformas").length;
        const nAdd = marcados("adicionais").length;

        $("#dica-plataformas").textContent = maxPlat
            ? `O plano ${p.dataset.nome} inclui ${maxPlat} plataformas (${nPlat} escolhidas).`
            : "Escolha onde quer anunciar. Se passar do que o plano inclui, o valor é combinado na proposta.";

        let dicaAdd = "Os adicionais fazem parte do Diamond. Marque os que fazem sentido para você.";
        if (p.value === "diamond") {
            dicaAdd = `O Diamond inclui ${maxAdd} funcionalidades adicionais (${nAdd} escolhidas).`;
        } else if (p.value === "gold") {
            dicaAdd = "Adicionais não fazem parte do Gold. Se marcar alguma, ela entra como extra, com valor combinado na proposta.";
        }
        $("#dica-adicionais").textContent = dicaAdd;
    }

    /* ---------- resumo ao vivo ---------- */
    function linhaResumo(rotulo, valor) {
        const linha = document.createElement("div");
        linha.className = "resumo-linha";
        const dt = document.createElement("dt");
        dt.textContent = rotulo;
        const dd = document.createElement("dd");
        dd.textContent = valor;
        linha.append(dt, dd);
        return linha;
    }

    function atualizarResumo() {
        const p = planoAtual();
        const linhas = [["Plano", p.dataset.nome]];

        if (p.dataset.preco) {
            linhas.push(["Valor", `a partir de ${p.dataset.preco}`]);
            linhas.push(["Cobrança", p.dataset.cobranca]);
        }

        const tipo = tipoAtual();
        if (tipo) linhas.push(["Projeto", TIPOS[tipo]]);

        if (!$('[data-bloco="site"]').hidden) {
            const n = marcados("basicas").length + marcados("adicionais").length;
            linhas.push(["Funcionalidades do site", String(n)]);
        }

        if (!$('[data-bloco="marketing"]').hidden) {
            const plataformas = marcados("plataformas").map((i) => NOMES[i.value]);
            if (plataformas.length) linhas.push(["Plataformas", plataformas.join(", ")]);
        }

        const orcamento = textoDoSelect("orcamento");
        if (orcamento) linhas.push(["Orçamento", orcamento]);

        const prazo = textoDoSelect("prazo");
        if (prazo) linhas.push(["Prazo", prazo]);

        resumo.replaceChildren(...linhas.map(([r, v]) => linhaResumo(r, v)));
    }

    function atualizar() {
        mostrarBlocos();
        atualizarLimitesEDicas();
        atualizarResumo();
    }

    /* ---------- troca de plano: ajusta o tipo e sugere plataformas ---------- */
    function aoTrocarPlano() {
        const p = planoAtual();

        if (p.dataset.tipo) form.elements["tipo"].value = p.dataset.tipo;

        // Prata: Instagram e YouTube já vêm marcados
        if (p.value === "prata" && marcados("plataformas").length === 0) {
            $$('input[name="plataformas"]', form).forEach((i) => {
                i.checked = i.value === "instagram" || i.value === "youtube";
            });
        }
        atualizar();
    }

    /* ---------- coleta dos dados (só de blocos visíveis) ---------- */
    function coletarDados() {
        const dados = {};
        $$("input, select, textarea", form).forEach((el) => {
            if (!el.name || el.disabled || el.closest("[hidden]")) return;
            if ((el.type === "checkbox" || el.type === "radio") && !el.checked) return;

            if (el.type === "checkbox") {
                (dados[el.name] = dados[el.name] || []).push(el.value);
            } else {
                dados[el.name] = el.value.trim();
            }
        });
        return dados;
    }

    /* ---------- validação ---------- */
    const REGEX_EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    function mensagemDeErro(campo) {
        if (campo.type === "checkbox") {
            return campo.checked ? "" : "Marque esta opção para enviar o pedido.";
        }
        const valor = campo.value.trim();
        if (!valor) return campo.tagName === "SELECT" ? "Escolha uma opção." : "Preencha este campo.";
        if (campo.type === "email" && !REGEX_EMAIL.test(valor)) {
            return "Digite um e-mail válido, como nome@empresa.com.";
        }
        if (campo.name === "telefone" && valor.replace(/\D/g, "").length < 10) {
            return "Digite o telefone com DDD.";
        }
        if (campo.name === "descricao" && valor.length < 30) {
            return "Conte um pouco mais: escreva pelo menos 30 caracteres.";
        }
        return "";
    }

    function validarCampo(campo) {
        const texto = mensagemDeErro(campo);
        const erro = campo.closest(".campo").querySelector(".erro");
        erro.textContent = texto;
        campo.setAttribute("aria-invalid", texto ? "true" : "false");
        return texto === "";
    }

    function validarFormulario() {
        let primeiroInvalido = null;
        $$("[data-obrigatorio]", form).forEach((campo) => {
            if (!validarCampo(campo) && !primeiroInvalido) primeiroInvalido = campo;
        });
        if (primeiroInvalido) {
            primeiroInvalido.focus();
            primeiroInvalido.scrollIntoView({
                behavior: movimentoReduzido ? "auto" : "smooth",
                block: "center",
            });
        }
        return primeiroInvalido === null;
    }

    /* ---------- máscaras ---------- */
    function mascaraTelefone(valor) {
        const n = valor.replace(/\D/g, "").slice(0, 11);
        if (n.length <= 2) return n;
        if (n.length <= 6) return `(${n.slice(0, 2)}) ${n.slice(2)}`;
        if (n.length <= 10) return `(${n.slice(0, 2)}) ${n.slice(2, 6)}-${n.slice(6)}`;
        return `(${n.slice(0, 2)}) ${n.slice(2, 7)}-${n.slice(7)}`;
    }

    function mascaraCnpj(valor) {
        const n = valor.replace(/\D/g, "").slice(0, 14);
        return n
            .replace(/^(\d{2})(\d)/, "$1.$2")
            .replace(/^(\d{2})\.(\d{3})(\d)/, "$1.$2.$3")
            .replace(/\.(\d{3})(\d)/, ".$1/$2")
            .replace(/(\d{4})(\d)/, "$1-$2");
    }

    form.elements["telefone"].addEventListener("input", (e) => {
        e.target.value = mascaraTelefone(e.target.value);
    });

    form.elements["cnpj"].addEventListener("input", (e) => {
        e.target.value = mascaraCnpj(e.target.value);
    });

    /* ---------- contador da descrição ---------- */
    form.elements["descricao"].addEventListener("input", (e) => {
        contador.textContent = `${e.target.value.length}/800`;
    });

    /* ---------- eventos gerais ---------- */
    form.addEventListener("change", (e) => {
        const alvo = e.target;

        if (alvo.name === "plano") {
            aoTrocarPlano();
            return;
        }

        if (alvo.name === "tipo") {
            // se o tipo não combina com o plano escolhido, volta para "Ainda não sei"
            const p = planoAtual();
            if (p.dataset.tipo && p.dataset.tipo !== tipoAtual()) {
                $("#plano-indefinido").checked = true;
            }
        }

        if (alvo.hasAttribute("data-obrigatorio")) validarCampo(alvo);
        atualizar();
    });

    form.addEventListener("input", (e) => {
        const alvo = e.target;
        if (alvo.hasAttribute("data-obrigatorio") && alvo.getAttribute("aria-invalid") === "true") {
            validarCampo(alvo);
        }
    });

    /* ---------- envio ---------- */
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        if (!validarFormulario()) return;

        const dados = coletarDados();

        // TODO (back-end): enviar o pedido para o servidor. Exemplo:
        // fetch("/api/demandas", {
        //     method: "POST",
        //     headers: { "Content-Type": "application/json" },
        //     body: JSON.stringify(dados),
        // });
        console.log("Pedido pronto para enviar:", dados);

        $("#sucesso-email").textContent = dados.email;
        form.hidden = true;
        sucesso.hidden = false;
        $("#sucesso-titulo").focus();
        window.scrollTo({ top: 0, behavior: movimentoReduzido ? "auto" : "smooth" });
    });

    $("#novo-pedido").addEventListener("click", () => {
        form.reset();
        $$(".erro", form).forEach((el) => (el.textContent = ""));
        $$("[aria-invalid]", form).forEach((el) => el.removeAttribute("aria-invalid"));
        contador.textContent = "0/800";
        sucesso.hidden = true;
        form.hidden = false;
        atualizar();
        window.scrollTo({ top: 0, behavior: movimentoReduzido ? "auto" : "smooth" });
    });

    /* ---------- início: lê ?plano=gold da URL (vem da página de planos) ---------- */
    const parametro = new URLSearchParams(window.location.search).get("plano");
    if (["prata", "gold", "diamond"].includes(parametro)) {
        $(`input[name="plano"][value="${parametro}"]`).checked = true;
        aoTrocarPlano();
    } else {
        atualizar();
    }
})();