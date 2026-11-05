/* =====================================================
   Página de cadastro
   - envia razão social, CNPJ, e-mail e telefone para o FastAPI
     (POST http://127.0.0.1:8000/usuario)
   ===================================================== */
   (function () {
    const API = "http://127.0.0.1:8000";

    const form = document.getElementById("form-cadastro");
    const msg = document.getElementById("msg-cadastro");
    const botao = form.querySelector("button[type=submit]");

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

    // O FastAPI devolve erros como {"detail": "texto"} ou, no caso de 422,
    // {"detail": [{"loc": [...], "msg": "..."}]}. Esta função vira texto.
    function textoDoErro(corpo) {
        if (!corpo || !corpo.detail) return "Não foi possível criar a conta.";
        if (typeof corpo.detail === "string") return corpo.detail;
        if (Array.isArray(corpo.detail)) {
            return corpo.detail
                .map((d) => `${(d.loc || []).slice(1).join(".")}: ${d.msg}`)
                .join(" | ");
        }
        return "Não foi possível criar a conta.";
    }

    form.addEventListener("submit", async (e) => {
        e.preventDefault();
        msg.textContent = "";

        const campos = {
            razao_social: form.elements["razao_social"].value.trim(),
            cnpj: form.elements["cnpj"].value.trim(),
            email: form.elements["email"].value.trim(),
            telefone: form.elements["telefone"].value.trim(),
        };

        if (Object.values(campos).some((v) => !v)) {
            msg.textContent = "Preencha todos os campos.";
            return;
        }
        if (campos.cnpj.replace(/\D/g, "").length !== 14) {
            msg.textContent = "Digite o CNPJ completo (14 números).";
            return;
        }

        const telefoneNumeros = campos.telefone.replace(/\D/g, "");
        if (telefoneNumeros.length < 10) {
            msg.textContent = "Digite o telefone com DDD (10 ou 11 números).";
            return;
        }

        // Nomes iguais aos do modelo usuarioEntrada.
        // CNPJ e telefone vão só com números, porque o modelo usa Decimal.
        

        const dados = {
             razao_social: campos.razao_social,
             cnpj: campos.cnpj.replace(/\D/g, ""),
            email: campos.email,
            telefone: campos.telefone.replace(/\D/g, "")
        };





        botao.disabled = true;
        try {
            const resposta = await fetch(`${API}/usuario`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(dados),
            });
            const corpo = await resposta.json().catch(() => ({}));

            if (!resposta.ok) {
                console.error("Erro do servidor:", resposta.status, corpo);
                msg.textContent = textoDoErro(corpo);
                botao.disabled = false;
                return;
            }
            window.location.href = "planos.html";
        } catch (erro) {
            console.error("Falha de rede:", erro);
            msg.textContent =
                "Não foi possível falar com o servidor. Confira se o uvicorn está rodando na porta 8000.";
            botao.disabled = false;
        }
    });
})();