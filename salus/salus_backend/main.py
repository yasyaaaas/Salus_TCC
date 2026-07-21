# main.py -> cria a aplicação FastAPI, define as rotas e as funções que serão executadas quando essas rotas forem acessadas

from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.database import Base, engine, get_db
from app.models.user import User
from app.schemas.schemas import UserCreate, UserOut, LoginRequest, TokenResponse, UserUpdate, ChatRequest, ChatResponse, ChatHistoryItem
from app.core.security import hash_password, verify_password, create_access_token, decode_access_token
from app.auth_deps import get_current_user
from app.services.chat_services import processar_mensagem_chat
from app.models.knowledge import Symptom, Condition, SymptomCondition  # noqa: F401
from app.models.chat import ChatMessage  # noqa: F401

app = FastAPI() # cria a plicação -> o qeu o Uvicorn procura

Base.metadata.create_all(bind=engine) # cria as tabelas no banco

@app.get("/") # quadno alguem acessar a rota raiz, ele vai executar a função home
def home():
    return {"status": "ok", "mensagem": "funciona!"} # um json de resposta para o usuário

# POST /users
@app.post("/users", response_model=UserOut, status_code=201) # quando alguem acessar a rota /users com o método POST, ele vai executar a função create_user
def create_user(data: UserCreate, db: Session = Depends(get_db)): # data: UserCreate -> o que o usuário manda na requisição, db: Session = Depends(get_db) -> cria uma sessão com o banco
                                 # toda vez que essa rota for chamada, roda o get_db pra mim e me entrega o resultado aqui, na variável db
    existe = db.query(User).filter(User.email == data.email).first() # busca no banco se já existe um usuário com o e-mail fornecido na requisição
    if existe:
        raise HTTPException(status_code=400, detail="E-mail já cadastrado")
    novo_usuario = User(
        full_name=data.full_name,
        email=data.email,
        hashed_password=hash_password(data.password), # senha criptografada
        age=data.age,
        weight_kg=data.weight_kg,
        height_cm=data.height_cm,
        gender=data.gender,
    )
    db.add(novo_usuario) # adiciona o novo usuário na sessão do banco
    db.commit() # salva as alterações no banco
    db.refresh(novo_usuario) # atualiza o objeto novo_usuario com os dados do banco (como o id gerado automaticamente)
    return novo_usuario # usa o userOut -> não devolve senha!

# POST /auth/loguin
@app.post("/auth/login", response_model=TokenResponse) # quando alguem acessar a rota /auth/login com o método POST, ele vai executar a função login
def login(data: LoginRequest, db: Session = Depends(get_db)):
    usuario = db.query(User).filter(User.email == data.email).first() # busca o usuário no banco pelo e-mail fornecido na requisição

    if not usuario or not verify_password(data.password, usuario.hashed_password): # verifica se o usuário existe e se a senha corresponde à senha criptografada armazenada no banco
        raise HTTPException(status_code=401, detail="E-mail ou senha incorretos")

    token = create_access_token(email=usuario.email) # cria o token de acesso do usuário com o e-mail do usuário que está logando -> para ele ficar logado
    return TokenResponse(access_token=token) # usa o TokenResponse -> devolve o token de acesso do usuário e o tipo do token (bearer)

# GET users/me
@app.get("/users/me", response_model=UserOut) # quando alguem acessar a rota /users/me com o método GET, ele vai executar a função get_current_user
def get_current_user_route(current_user: User = Depends(get_current_user)): # current_user: extrai o usuário atual da requisição, se não tiver token, retorna erro de credencial
    return current_user # usa o userOut -> não devolve senha!

# PUT /users/edit
@app.put("/users/edit", response_model=UserOut) # quando alguem acessar a rota /users/edit com o método PUT, ele vai executar a função update_profile
def update_profile(
    data: UserUpdate,
    usuario_atual: User = Depends(get_current_user),
    db: Session = Depends(get_db),
): # altera os dados do usuário atual, se não tiver token, retorna erro de credencial
    if data.full_name is not None:
        usuario_atual.full_name = data.full_name
    if data.age is not None:
        usuario_atual.age = data.age
    if data.weight_kg is not None:
        usuario_atual.weight_kg = data.weight_kg
    if data.height_cm is not None:
        usuario_atual.height_cm = data.height_cm
    if data.gender is not None:
        usuario_atual.gender = data.gender
    if data.avatar is not None:
        usuario_atual.avatar = data.avatar

    db.commit() # salva as alterações no banco
    db.refresh(usuario_atual) # atualiza o objeto usuario_atual com os dados do banco
    return usuario_atual # usa o userOut -> não devolve senha!

# POST /chat
@app.post("/chat", response_model=ChatResponse) # quando acessar a rota o usuário vai mandara sua mensagem do qeu está sentindo
def chat(
    data: ChatRequest,
    usuario_atual: User = Depends(get_current_user), # assim preisa do token
    db: Session = Depends(get_db),
):
    resultado = processar_mensagem_chat(data.mensagem, db) # manda mensagem pro user e devolve

    nova_mensagem = ChatMessage(
        user_id=usuario_atual.id,
        mensagem_usuario=data.mensagem,
        resposta_chatbot=resultado["resposta"],
        manchester_color=resultado["manchester_color"],
        manchester_label=resultado["manchester_label"],
    )

    db.add(nova_mensagem) # salva no banco a mensagem do usuário a resposta + outros
    db.commit()
    return resultado # volta a mensagem do chat

# GET /chat/history
@app.get("/chat/history", response_model=list[ChatHistoryItem]) # vai voltar as mensagens do usuário
def get_chat_history(
    usuario_atual: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    mensagens = (
        db.query(ChatMessage) #  buscar coisas na tabela chat_messages
        .filter(ChatMessage.user_id == usuario_atual.id) # filtra pelo id do usuário
        .order_by(ChatMessage.created_at.desc()) # ordena pelo mais recente primeiro
        .all() # devolve todos os resultados
    )
    return mensagens # devolve eles