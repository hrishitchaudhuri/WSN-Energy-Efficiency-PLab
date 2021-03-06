

clc; clear all; close all;

%%%%%%%%%%%%%%%%%%%% Network Establishment Parameters %%%%%%%%%%%%%%%%%%%%

%%% Area of Operation %%%

% Field Dimensions in meters %
xm=100;
ym=100;
% radius_network = 130;
x=0; % added for better display results of the plot
y=0; % added for better display results of the plot

%%Number of clusters
Nchs = 5;
% Number of Nodes in the field %
n=100;
angle_sector = 2*pi/Nchs;
%Radius of field and origin
radius_field = 100;
x0 = 0;
y0 = 0;
% Number of Dead Nodes in the beggining %
dead_nodes=0;

% Coordinates of the Sink (location is predetermined in this simulation) %
sinkx=0;
sinky=0;

%%% Energy Values %%%
% Initial Energy of a Node (in Joules) % 
Eo=0.5; % units in Joules

% Energy required to run circuity (both for transmitter and receiver) %
Eelec=50*10^(-9); % units in Joules/bit

% Transmit Amplifier Types %
Eamp=100*10^(-12); % units in Joules/bit/m^2 (amount of energy spent by the amplifier to transmit the bits)

% Data Aggregation Energy %
EDA=5*10^(-9); % units in Joules/bit

% Size of data package %
k=500; % units in bits


% Radius of circular trajectory of mobile sink
radius = 25;

% Round of Operation %
rnd=0;

% Efs and Emp values
Efs = 10*10^(-12);
Emp = 13*10^(-16);

% Threshold for nodes
do = sqrt(Efs/Emp);

% Current Number of operating Nodes %
operating_nodes=n;
transmissions=0;
temp_val=0;
flag1stdead=0;

% Mobile sink initial positions
ms_Po.x = sinkx+radius;
ms_Po.y = sinky;


% Threshold distance for nodes
threshold = 30;
%%%%%%%%%%%%%%%%%%%%%%%%%%% End of Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%



            %%% Creation of the Wireless Sensor Network %%%



figure(1);
viscircles([x0,y0],radius_field);
hold on;
for i=1:n
    t = 2*pi*rand(1,1);
    r = radius_field*sqrt(rand(1,1));
    S(i, 1) = x0 + r*cos(t);
    S(i, 2) = y0 + r*sin(t);
%     plot(S(i, 1), S(i, 2), 'red .');
    title 'Wireless Sensor Network';
    xlabel '(m)';
    ylabel '(m)';
    hold on;
end
%Creating sectors
a2 = 0;
for i = 1:Nchs
    a1 = a2;  % A random direction
    a2 = a1 + angle_sector;
    t = linspace(a1,a2);
    x = x0 + radius_field*cos(t);
    y = y0 + radius_field*sin(t);
    plot([x0,x,x0],[y0,y,y0],'k --')
    axis equal
end        

for i=1:n
    
    SN(i).id=i;	% sensor's ID number
    SN(i).x=S(i, 1);	% X-axis coordinates of sensor node
    SN(i).y=S(i, 2);	% Y-axis coordinates of sensor node
    SN(i).E=Eo;     % nodes energy levels (initially set to be equal to "Eo"
    SN(i).role=0;   % node acts as normal if the value is '0', if elected as a cluster head it  gets the value '1' (initially all nodes are normal)
%     SN(i).cluster=0;	% the cluster which a node belongs to
    SN(i).cond=1;	% States the current condition of the node. when the node is operational its value is =1 and when dead =0
    SN(i).rop=0;	% number of rounds node was operational
    SN(i).rleft=0;  % rounds left for node to become available for Cluster Head election
    SN(i).dtch=0;	% nodes distance from the cluster head of the cluster in which he belongs
    SN(i).dts=0;    % nodes distance from the sink
    SN(i).tel=0;	% states how many times the node was elected as a Cluster Head
    SN(i).rn=0;     % round node got elected as cluster head
    SN(i).chid=0;   % node ID of the cluster head which the "i" normal node belongs to
    SN(i).route=[];
    

end

for i=1:n
    if(SN(i).x>=0&&SN(i).y>=0)
        SN(i).cluster = ceil((atan(SN(i).y/SN(i).x))/angle_sector);
    elseif(SN(i).x<0)
        SN(i).cluster = ceil((atan(SN(i).y/SN(i).x)+pi)/angle_sector);
    elseif(SN(i).x>=0&&SN(i).y<0)
        SN(i).cluster = ceil((atan(SN(i).y/SN(i).x)+2*pi)/angle_sector);
    end
end
for i=1:n
    if(SN(i).cluster==1)

        plot(SN(i).x,SN(i).y,'og');    
        title 'Wireless Sensor Network';
        xlabel '(m)';
        ylabel '(m)';    
    elseif(SN(i).cluster==2)
        plot(SN(i).x,SN(i).y,'ob');    
        title 'Wireless Sensor Network';
        xlabel '(m)';
        ylabel '(m)';    
    elseif(SN(i).cluster==3)
        plot(SN(i).x,SN(i).y,'*b');    
        title 'Wireless Sensor Network';
        xlabel '(m)';
        ylabel '(m)';    
    elseif(SN(i).cluster==4)    
        plot(SN(i).x,SN(i).y,'*g');    
        title 'Wireless Sensor Network';
        xlabel '(m)';
        ylabel '(m)';    
    elseif(SN(i).cluster==5)
        plot(SN(i).x,SN(i).y,'.r',sinkx,sinky,'*r');    
        title 'Wireless Sensor Network';
        xlabel '(m)';
        ylabel '(m)';    
    end
end


while operating_nodes>0
    viscircles([sinkx,sinky],radius);
    if ((mod(rnd,4)==0))
        ms_Po.x = sinkx+radius;
        ms_Po.y = sinky;
    end
    if(mod(rnd,4)==1)
        ms_Po.x = sinkx;
        ms_Po.y = sinky+radius;
    end
    if(mod(rnd,4)==2)
        ms_Po.x = sinkx-radius;
        ms_Po.y = sinky;
    end
    if(mod(rnd,4)==3)
        ms_Po.x = sinkx;
        ms_Po.y = sinky-radius;
    end
    plot(ms_Po.x,ms_Po.y,'o','Linewidth',3);
    
    
% Reseting Previous Amount Of Energy Consumed In the Network on the Previous Round %
    energy=0;
    j=1; 
 
% Cluster Heads Election %
    for i=1:n
        SN(i).role = 0;
        SN(i).chid = 0;
        SN(i).dcir = 0;
        SN(i).weight = 0;        
        if(SN(i).E>0)
            SN(i).dcir = sqrt((SN(i).x-ms_Po.x)^2+(SN(i).y-ms_Po.y)^2);
            SN(i).weight = (SN(i).E)^2/SN(i).dcir;
        end
    end


    for k=1:Nchs
        cluster = zeros;
        counter=1;
        CH(k).num_nodes = 0;
        CH(k).id = 0;
        CH(k).weight = 0;
        CH(k).dcir = 0;        
        for j=1:n
            if(SN(j).cond==1&&SN(j).cluster==k)
                cluster(counter,1) = j;
                cluster(counter,2) = SN(j).weight;
                CH(k).num_nodes = counter;
                counter = counter+1;
            end
        end
        [CH(k).weight,CH(k).id] = max(cluster(:,2));
        CH(k).id = cluster(CH(k).id,1);
        CH(k).dcir = SN(CH(k).id).dcir;
        DCIR(k) = CH(k).dcir;
        SN(CH(k).id).role = 1;
        CH(k).path =0;
        CH(k).route = [];
    end
    
    
    
    
%     Distance from nodes to CH
    for i=1:n
        if(SN(i).role==0)
            SN(i).chid = CH(SN(i).cluster).id;
            SN(i).dtch = sqrt((SN(i).x-SN(SN(i).chid).x)^2+(SN(i).y-SN(SN(i).chid).y)^2);
        end
    end
    
    
% %     Shortest path for nodes to their respective CH
%     G = graph();
%     for i = 1:1:n
%     if(findnode(G,i)==0)
%     G=addnode(G,i);
%     end
%     for j = i:1:n
%         if (SN(i).cluster==SN(j).cluster&&(i~=j))
%             if((SN(i).dtch<=threshold)&&(findnode(G,SN(i).chid)~=0)&(findedge(G,i,SN(i).chid)==0))
%                 G = addedge(G, i, SN(i).chid, SN(i).dtch);
%             elseif(findnode(G,SN(i).chid)==0)
%                 G = addedge(G, i, SN(i).chid, SN(i).dtch);
%             end
% 
%             node_dist = ((SN(i).x - SN(j).x)^2 + (SN(i).y - SN(j).y)^2);
%             if node_dist < threshold
%                 G = addedge(G, i, j, node_dist);
%             end
%         end
%     end
%     end
% 
%     for i = 1:1:n
%         SN(i).route = shortestpath(G, i, SN(i).chid);
%     end
    
    
%     Finding Leader CH
    min_dcir = min(DCIR);
    for i=1:Nchs
        if(CH(i).dcir==min_dcir)
            leader_CH_id = CH(i).id;
        end
    end
    
    
    
% distance from CH to Leader CH
for i = 1:Nchs
    CH(i).dist=sqrt((SN(leader_CH_id).x-SN(CH(i).id).x)^2 + (SN(leader_CH_id).y-SN(CH(i).id).y)^2);
end

% distance from CH to next nearest neighbouring CH
    nearest_neighbour=zeros;
    for i=1:Nchs
        for j=i:Nchs
            if(SN(CH(i).id).cond==1&&(i~=j))
            nearest_neighbour(i,j)=sqrt((SN(CH(i).id).x-SN(CH(j).id).x)^2 + (SN(CH(i).id).y-SN(CH(j).id).y)^2);
            nearest_neighbour(j,i)=sqrt((SN(CH(i).id).x-SN(CH(j).id).x)^2 + (SN(CH(i).id).y-SN(CH(j).id).y)^2);
            end
            if(SN(CH(i).id).cond==1&&(i==j))
            nearest_neighbour(i,j)=inf;
            end
        end
    end
    
    

% Greedy Algorithm for CHs
for i=1:Nchs
    if(CH(i).id~=leader_CH_id)
    [neigh_CHs_dis,neigh_CHs_id] = find_neigh_CHs(i,nearest_neighbour,Nchs);
    for j=1:Nchs
        if((CH(neigh_CHs_id(j)).dist<CH(i).dist)&&(CH(neigh_CHs_id(j)).path<2)&&(CH(neigh_CHs_id(j)).id~=leader_CH_id))
                    CH(i).path=CH(i).path+1;
                    CH(neigh_CHs_id(j)).path=CH(neigh_CHs_id(j)).path+1;
                    CH(i).route(length(CH(i).route)+1) = neigh_CHs_id(j); 
                    break;
        elseif((CH(neigh_CHs_id(j)).dist<CH(i).dist)&&(CH(neigh_CHs_id(j)).id==leader_CH_id))
                CH(i).path=CH(i).path+1;
                CH(neigh_CHs_id(j)).path=CH(neigh_CHs_id(j)).path+1;
                CH(i).route(length(CH(i).route)+1) = neigh_CHs_id(j); 
                break;
        end
    end
    else
        CH(i).route = i;
    end
end 


% Updating distance of CHs to closest CH
for i=1:Nchs
    CH(i).dist=sqrt((SN(CH(CH(i).route).id).x-SN(CH(i).id).x)^2 + (SN(CH(CH(i).route).id).y-SN(CH(i).id).y)^2); 
end    
 
% % % % % % % % % % % % % % % % % % % Steady Phase%%%%%%%%%%%%%%%%%

% Energy Dissipation for normal nodes %
    
    for i=1:n
       if (SN(i).cond==1) && (SN(i).role==0)
       	if SN(i).E>0
            if(SN(i).dtch<do)
                ETx= Eelec*k + Efs*k*SN(i).dtch^2;
                SN(i).E=SN(i).E - ETx;
                energy=energy+ETx;
                disp(1);
            else
                ETx= Eelec*k + Emp*k*SN(i).dtch^4;
                SN(i).E=SN(i).E - ETx;
                energy=energy+ETx;
                disp(1);
            end            
                     
        % Dissipation for cluster head during reception
        if SN(SN(i).chid).E>0 && SN(SN(i).chid).cond==1 && SN(SN(i).chid).role==1
            ERx=(Eelec)*k*CH(SN(i).cluster).num_nodes;
            energy=energy+ERx;
            SN(SN(i).chid).E=SN(SN(i).chid).E - ERx;
            disp(2);
             if SN(SN(i).chid).E<=0  % if cluster heads energy depletes with reception
                SN(SN(i).chid).cond=0;
                SN(SN(i).chid).rop=rnd;
                dead_nodes=dead_nodes +1;
                operating_nodes= operating_nodes - 1;
                 dead_nodes_check(rnd,1) = SN(i).chid;
                 dead_nodes_check(rnd,2) = 1;
             end
        end   
        end
        if SN(i).E<=0       % if nodes energy depletes with transmission
        dead_nodes=dead_nodes +1;
        operating_nodes= operating_nodes - 1;
        SN(i).cond=0;
        SN(i).chid=0;
        SN(i).rop=rnd;
        dead_nodes_check(rnd,1) = i;
        dead_nodes_check(rnd,2) = 2;
        end
        
      end
    end   
    

    
% Energy Dissipation for cluster head nodes %
   
   for i=1:Nchs
     if (SN(CH(i).id).cond==1)  && (SN(CH(i).id).role==1 ) && (CH(i).id~=leader_CH_id)
         if (SN(CH(i).id).E)>0
            if(CH(i).dist<do)
            ETx= (Eelec)*k*CH(i).num_nodes + Efs*CH(i).num_nodes*k*CH(i).dist^2;
            SN(CH(i).id).E=SN(CH(i).id).E- ETx;
            energy=energy+ETx;
            disp(3);
            else
            ETx= (Eelec)*k*CH(i).num_nodes + Emp*k*CH(i).num_nodes*CH(i).dist^4;
            SN(CH(i).id).E=SN(CH(i).id).E- ETx;
            energy=energy+ETx;
            disp(3);
            end
         end
         if  SN(CH(i).id).E<=0     % if cluster heads energy depletes with transmission
         dead_nodes=dead_nodes +1;
         operating_nodes= operating_nodes - 1;
         SN(CH(i).id).cond=0;
         SN(CH(i).id).rop=rnd;
         dead_nodes_check(rnd,1) = CH(i).id;
         dead_nodes_check(rnd,2) = 3;
         end
     
     elseif(SN(CH(i).id).cond==1)  && (SN(CH(i).id).role==1 ) && (CH(i).id==leader_CH_id)
         if (SN(CH(i).id).E)>0
            if(CH(i).dcir<do)
            ETx= (Eelec)*k*operating_nodes + Efs*k*operating_nodes*CH(i).dcir^2;
            SN(CH(i).id).E=SN(CH(i).id).E- ETx;
            energy=energy+ETx; 
            disp(3);
            else
            ETx= (Eelec)*k*operating_nodes + Emp*k*operating_nodes*CH(i).dcir^4;
            SN(CH(i).id).E=SN(CH(i).id).E-ETx;
            energy=energy+ETx;
            disp(3);
            end
         end
         if  SN(CH(i).id).E<=0     % if cluster heads energy depletes with transmission
         dead_nodes=dead_nodes + 1;
         operating_nodes= operating_nodes - 1;
         SN(CH(i).id).cond=0;
         SN(CH(i).id).rop=rnd;
         dead_nodes_check(rnd,1) = CH(i).id;
         dead_nodes_check(rnd,2) = 4;
         end
     end
   end    
   
   
% Energy reception of CHs due to Greedy Algorithm

    for i=1:Nchs
      if((SN(CH(CH(i).route).id).E>0)&&(SN(CH(CH(i).route).id).cond==1)&&(SN(CH(CH(i).route).id).role==1)&&(CH(i).id~=leader_CH_id))
          ERx=(Eelec)*k*CH(CH(i).route).num_nodes;
          energy=energy+ERx;
          SN(CH(CH(i).route).id).E=SN(CH(CH(i).route).id).E - ERx;
          disp(4);
          if SN(CH(CH(i).route).id).E<=0  % if cluster heads energy depletes with reception
              SN(CH(CH(i).route).id).cond=0;
              SN(CH(CH(i).route).id).rop=rnd;
              dead_nodes=dead_nodes +1;
              operating_nodes= operating_nodes - 1;
              dead_nodes_check(rnd,1) = CH(CH(i).route).id;
              dead_nodes_check(rnd,2) = 5;
          end       
      end
    end
    
    
    if operating_nodes<n && temp_val==0
        temp_val=1;
        flag1stdead=rnd;
    end
    % Display Number of Cluster Heads of this round %
    %CLheads;
   
    
    transmissions=transmissions+1;
%     if CLheads==0
%     transmissions=transmissions-1;
%     end
%     
 
    % Next Round %
    rnd= rnd +1;
    
    tr(transmissions)=operating_nodes;
    op(rnd)=operating_nodes;
    avg_res_nodes(rnd,5) = operating_nodes; %for average of multiple simulations 
    

    if energy>0
    nrg(transmissions)=energy;
    end
    
    
    
    
%        if operating_nodes==8
%            break;
%        end

disp(operating_nodes);
fprintf('rnd = %d',rnd);
disp(flag1stdead);
   
end



function[neigh_CHs_dis,neigh_CHs_id] = find_neigh_CHs(i,nearest_neighbour,Nchs)
    neigh_CHs_id = [];
    neigh_CHs_dis = nearest_neighbour(i,:);
    neigh_CHs_dis = sort(neigh_CHs_dis);
    for j =1:Nchs
        for k=1:Nchs
            if(neigh_CHs_dis(j)==nearest_neighbour(i,k))
                neigh_CHs_id(length(neigh_CHs_id)+1) = k;
            end
        end
    end
end

